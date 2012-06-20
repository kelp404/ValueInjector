//
//  ValueInjector.m
//  ValueInjector   1.0.5
//
//  Created by Kelp on 12/5/6.
//  Copyright (c) 2012 Kelp http://kelp.phate.org/
//  MIT License
//

#import "ValueInjector.h"


#pragma mark - PropertyModel
@interface PropertyModel : NSObject
#if __has_feature(objc_arc)
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *attributes;
#else
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *attributes;
#endif
@end
@implementation PropertyModel
@synthesize name, attributes;
@end


#pragma mark - ValueInjectorUtility
@interface ValueInjectorUtility : NSObject
- (NSArray *)getPropertyList:(Class)cls;
@end
@implementation ValueInjectorUtility
- (NSArray *)getPropertyList:(Class)cls
{
#if __has_feature(objc_arc)
    NSMutableArray *result = [NSMutableArray new];
#else
    NSMutableArray *result = [[NSMutableArray new] autorelease];
#endif
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([cls class], &count);
    
    for (unsigned int index = 0; index < count; index++) {
#if __has_feature(objc_arc)
        PropertyModel *model = [PropertyModel new];
#else
        PropertyModel *model = [[PropertyModel new] autorelease];
#endif
        objc_property_t property = properties[index];
        
        model.name = [NSString stringWithUTF8String:property_getName(property)];
        model.attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        [result addObject:model];
    }
    free(properties);
    
    // scan super class
    Class superCls = class_getSuperclass([cls class]);
    NSString *superName = [NSString stringWithUTF8String:class_getName(superCls)];
    if (![superName isEqualToString:@"NSObject"]) {
        NSArray *superProperties = [self getPropertyList:superCls];
        [result addObjectsFromArray:superProperties];
    }
    return result;
}
@end


#pragma mark - ValueInjector
@implementation NSObject (ValueInjector)
// Inject value from NSDictionary to custom class
- (id)injectFromObject:(NSObject *)object
{
    return [self injectFromObject:object arrayClass:nil];
}
- (id)injectFromObject:(NSObject *)object arrayClass:(__unsafe_unretained Class)cls
{
    // list properties of custom class and inject value
#if __has_feature(objc_arc)
    ValueInjectorUtility *viu = [ValueInjectorUtility new];
#else
    ValueInjectorUtility *viu = [[ValueInjectorUtility new] autorelease];
#endif
    NSArray *properties = [viu getPropertyList:[self class]];
    
    for (unsigned int index = 0; index < [properties count]; index++) {
        PropertyModel *property = [properties objectAtIndex:index];
        
        id value = [object valueForKey:property.name];
        
        if (value == nil || [value isKindOfClass:[NSNull class]])
            continue;
        
        if ([property.attributes rangeOfString:@"T@\""].location != NSNotFound) {
            // the type of peoperty is class
            int endIndex = [property.attributes rangeOfString:@"\"" options:NSLiteralSearch range:NSMakeRange(3, [property.attributes length] - 4)].location;
            // get class type name from attributes of property
            NSString *className = [property.attributes substringWithRange:NSMakeRange(3, endIndex - 3)];
            
            // NSString or NSNumber
            if ([className isEqualToString:@"NSString"] ||
                [className isEqualToString:@"NSNumber"]) {
                [self setValue:value forKey:property.name];
            }
            // NSDate
            else if ([className isEqualToString:@"NSDate"]) {
                if (value != nil) {
#if __has_feature(objc_arc)
                    NSDateFormatter *dateFormatter = [NSDateFormatter new];
#else
                    NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
#endif
                    [dateFormatter setDateFormat:ValueInjectorTimeFormate];
                    [self setValue:[dateFormatter dateFromString:value] forKey:property.name];
                }
                else {
                    [self setValue:nil forKey:property.name];
                }
            }
            // NSDictionary
            else if ([className isEqualToString:@"NSDictionary"]) {
                // stop inject children propertis and reconstruct NSDictionary
                if (value == nil || [value isKindOfClass:[NSNull class]]) {
                    [self setValue:value forKey:property.name];
                }
                else {
                    @try {
                        [self setValue:[NSDictionary dictionaryWithDictionary:value] forKey:property.name];
                    }
                    @catch (NSException *exception) {
                        [self setValue:value forKey:property.name];
                    }   
                }
            }
            // NSArray
            else if ([className isEqualToString:@"NSArray"]) {
#if __has_feature(objc_arc)
                id testModel = [cls new];
#else
                id testModel = [[cls new] autorelease];
#endif
                // test model init success
                if (testModel == nil || [testModel isKindOfClass:[NSNull class]]) {
                    [self setValue:value forKey:property.name];
                }
                else {
#if __has_feature(objc_arc)
                    NSMutableArray *result = [NSMutableArray new];
#else
                    NSMutableArray *result = [[NSMutableArray new] autorelease];
#endif
                    // list all item in NSArray
                    for (id item in value) {
#if __has_feature(objc_arc)
                        id model = [cls new];
#else
                        id model = [[cls new] autorelease];
#endif
                        [model injectFromObject:item];
                        // put model into result array
                        if (model == nil || [model isKindOfClass:[NSNull class]]) {
                            [result addObject:[NSNull null]];
                        }
                        else {
                            [result addObject:model];
                        }
                    }
                    // inject value to property of custom class
                    [self setValue:[NSArray arrayWithArray:result] forKey:property.name];
                }
            }
            // custom class
            else {
                Class cl = NSClassFromString(className);
#if __has_feature(objc_arc)
                id model = [cl new];
#else
                id model = [[cl new] autorelease];
#endif
                [model injectFromObject:value];
                [self setValue:model forKey:property.name];
            }
        }
        else {
            // the type of member is not class
            [self setValue:value forKey:property.name];
        }
    }
    
    return self;
}

// Inject value from .NET Nonsensical dictionary serialization
// Nonsensical dictionary serialization : http://stackoverflow.com/questions/4559991/any-way-to-make-datacontractjsonserializer-serialize-dictionaries-properly
- (id)injectFromdotNewDictionary:(NSArray *)object
{
    for (unsigned int index = 0; index < [object count]; index++) {
        NSDictionary *target = [object objectAtIndex:index];
        NSString *targetName = [target objectForKey:@"Key"];
        objc_property_t property = class_getProperty([self class], [targetName cStringUsingEncoding:NSUTF8StringEncoding]);
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        // NSDate
        if ([attributes isEqualToString:@"T@\"NSDate"]) {
#if __has_feature(objc_arc)
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
#else
            NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
#endif
            [dateFormatter setDateFormat:ValueInjectorTimeFormate];
            [self setValue:[dateFormatter dateFromString:[target objectForKey:@"Value"]] forKey:targetName];
        }
        // other classes
        else {
            [self setValue:[target objectForKey:@"Value"] forKey:targetName];
        }
    }
    
    return self;
}
@end

@implementation NSDictionary (ValueInjector)
// init NSDictionary with custom class
- (id)initWithObject:(NSObject *)object
{
    NSMutableArray *content = [NSMutableArray new];
    NSMutableArray *key = [NSMutableArray new];
    
    // get properties of custom class
#if __has_feature(objc_arc)
    ValueInjectorUtility *viu = [ValueInjectorUtility new];
#else
    ValueInjectorUtility *viu = [[ValueInjectorUtility new] autorelease];
#endif
    NSArray *properties = [viu getPropertyList:[object class]];
    
    // no property
    if ([properties count] == 0) {
        return (id)object;
    }
    
    // member is property
    for (unsigned int index = 0; index < [properties count]; index++) {
        PropertyModel *property = [properties objectAtIndex:index];
        
        id value = [object valueForKey:property.name];
        [key addObject:property.name];
        
        if (value == nil || [value isKindOfClass:[NSNull class]])  //value is null
            [content addObject:[NSNull null]];
        else {
            if ([property.attributes rangeOfString:@"T@\""].location != NSNotFound) {
                // the type of member is class
                int endIndex = [property.attributes rangeOfString:@"\"" options:NSLiteralSearch range:NSMakeRange(3, [property.attributes length] - 4)].location;
                NSString *className = [property.attributes substringWithRange:NSMakeRange(3, endIndex - 3)];
                
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
#if __has_feature(objc_arc)
                        [content addObject:[NSDictionary new]];
#else
                        [content addObject:[[NSDictionary new] autorelease]];
#endif
                    }
                }
                else if ([className isEqualToString:@"NSArray"]) {
                    NSArray *source = value;
                    @try {
                        if (value == nil || [value isKindOfClass:[NSNull class]] || [source count] == 0) {
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
#if __has_feature(objc_arc)
                                NSMutableArray *output = [NSMutableArray new];
#else
                                NSMutableArray *output = [[NSMutableArray new] autorelease];
#endif
                                for (id item in source) {
#if __has_feature(objc_arc)
                                    NSDictionary *dic = [[NSDictionary alloc] initWithObject:item];
#else
                                    NSDictionary *dic = [[[NSDictionary alloc] initWithObject:item] autorelease];
#endif
                                    [output addObject:dic];
                                }
                                [content addObject:[NSArray arrayWithArray:output]];
                            }
                        }
                    }
                    @catch (NSException *exception) {
#if __has_feature(objc_arc)
                        [content addObject:[NSArray new]];
#else
                        [content addObject:[[NSArray new] autorelease]];
#endif
                    }
                }
                else {
                    // custom class
#if __has_feature(objc_arc)
                    NSDictionary *dic = [[NSDictionary alloc] initWithObject:value];
#else
                    NSDictionary *dic = [[[NSDictionary alloc] initWithObject:value] autorelease];
#endif
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
    
#if !__has_feature(objc_arc)
    [content release];
    [key release];
#endif
    
    return self;
}
@end