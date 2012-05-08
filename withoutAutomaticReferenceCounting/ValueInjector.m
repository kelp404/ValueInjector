//
//  ValueInjector.m
//  ValueInjector   1.0 without Objective-C Automatic Reference Counting
//
//  Created by Kelp on 12/5/6.
//  Copyright (c) 2012年 Kelp http://kelp.phate.org/
//  MIT License
//

#import "ValueInjector.h"

@implementation NSObject (ValueInjector)
// Inject value from NSDictionary to custom class
- (id)injectFromObject:(NSObject *)object
{
    // get the name of custom class
    NSString *targetClassName = [NSString stringWithUTF8String:class_getName([self class])];
    
    // list properties of custom class and inject value
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int index = 0; index < propertyCount; index++) {
        objc_property_t property = properties[index];
        
        // get property name of custom class
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        id value = [object valueForKey:name];
        
        if (value == NULL)
            continue;
        
        if ([attributes rangeOfString:@"T@\""].length > 0) {
            // the type of peoperty is class
            int endIndex = [attributes rangeOfString:@"\"" options:NSLiteralSearch range:NSMakeRange(3, [attributes length] - 4)].location;
            // get class type name from attributes of property
            NSString *className = [attributes substringWithRange:NSMakeRange(3, endIndex - 3)];
            
            if ([className isEqualToString:@"NSString"] ||
                [className isEqualToString:@"NSNumber"]) {
                [self setValue:value forKey:name];
            }
            // NSDictionary
            else if ([className isEqualToString:@"NSDictionary"]) {
                // stop inject children propertis and reconstruct NSDictionary
                if (value == NULL) {
                    [self setValue:value forKey:name];
                }
                else {
                    @try {
                        [self setValue:[NSDictionary dictionaryWithDictionary:value] forKey:name];
                    }
                    @catch (NSException *exception) {
                        [self setValue:value forKey:name];
                    }   
                }
            }
            // NSArray
            else if ([className isEqualToString:@"NSArray"]) {
                NSString *clName = [targetClassName substringFromIndex:[targetClassName length] - 5];
                if ([clName isEqualToString:@"Model"]) {
                    clName = [NSString stringWithFormat:@"%@%@", [targetClassName substringToIndex:[targetClassName length] - 5], name];
                }
                else {
                    clName = [NSString stringWithFormat:@"%@%@", clName, name];
                }
                Class cl = NSClassFromString(clName);
                id testModel = [[[cl alloc] init] autorelease];
                // test model init success
                if (testModel == NULL) {
                    [self setValue:value forKey:name];
                }
                else {
                    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
                    // list all item in NSArray
                    for (id item in value) {
                        id model = [[[cl alloc] init] autorelease];
                        [model injectFromObject:item];
                        // put model into result array
                        if (model == NULL) {
                            [result addObject:[NSNull null]];
                        }
                        else {
                            [result addObject:model];
                        }
                    }
                    // inject value to property of custom class
                    [self setValue:[NSArray arrayWithArray:result] forKey:name];
                }
            }
            // custom class
            else {
                Class cl = NSClassFromString(className);
                id model = [[[cl alloc] init] autorelease];
                [model injectFromObject:value];
                [self setValue:model forKey:name];
            }
        }
        else {
            // the type of member is not class
            [self setValue:value forKey:name];
        }
    }
    free(properties);

    return self;
}
@end

@implementation NSDictionary (ValueInjector)
// init NSDictionary with custom class
- (id)initWithObject:(NSObject *)object
{
    NSMutableArray *content = [[NSMutableArray alloc] init];
    NSMutableArray *key = [[NSMutableArray alloc] init];
    
    unsigned int propertyCount = 0;
    // get properties of custom class
    objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
    
    // no property
    if (propertyCount == 0) {
        return (id)object;
    }
    
    //member is property
    for (unsigned int index = 0; index < propertyCount; index++) {
        objc_property_t property = properties[index];
        
        NSString *name = [[NSString stringWithUTF8String:property_getName(property)] autorelease];
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        id value = [object valueForKey:name];
        [key addObject:name];     
        
        if (value == NULL)  //value is null
            [content addObject:[NSNull null]];
        else {
            if ([attributes rangeOfString:@"T@\""].length > 0) {
                // the type of member is class
                int endIndex = [attributes rangeOfString:@"\"" options:NSLiteralSearch range:NSMakeRange(3, [attributes length] - 4)].location;
                NSString *className = [attributes substringWithRange:NSMakeRange(3, endIndex - 3)];
                
                if ([className isEqualToString:@"NSString"] ||
                    [className isEqualToString:@"NSNumber"]) {
                    [content addObject:value];
                }
                else if ([className isEqualToString:@"NSDictionary"]) {
                    //NSDictionary
                    @try {
                        [content addObject:[NSDictionary dictionaryWithDictionary:value]];
                    }
                    @catch (NSException *exception) {
                        [content addObject:[[[NSDictionary alloc] init] autorelease]];
                    }
                }
                else if ([className isEqualToString:@"NSArray"]) {
                    NSArray *source = value;
                    @try {
                        if (value == NULL || [source count] == 0) {
                            //array is empty
                            [content addObject:value];
                        }
                        else {
                            NSString *arrayContent = [NSString stringWithUTF8String:class_getName([[source objectAtIndex:0] class])];
                            if ([arrayContent isEqualToString:@"NSString"] ||
                                [arrayContent isEqualToString:@"NSNumber"]) {
                                [content addObject:value];
                            }
                            else {
                                // there are class type in array
                                NSMutableArray *output = [[[NSMutableArray alloc] init] autorelease];
                                for (id item in source) {
                                    NSDictionary *dic = [[[NSDictionary alloc] initWithObject:item] autorelease];
                                    [output addObject:dic];
                                }
                                [content addObject:[NSArray arrayWithArray:output]];
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        [content addObject:[[[NSArray alloc] init] autorelease]];
                    }
                }
                else {
                    // custom class
                    NSDictionary *dic = [[[NSDictionary alloc] initWithObject:value] autorelease];
                    [content addObject:dic];
                }
            }
            else {
                //the type of member is not class
                [content addObject:value];
            }
        }
    }
    self = [self initWithObjects:content forKeys:key];
    
    free(properties);
    [content release];
    [key release];
    
    return self;
}
@end