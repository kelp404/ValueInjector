//
//  ValueInjector.m
//  ValueInjector   1.0.7
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
#else
@property (retain, nonatomic) NSString *name;
#endif
@property (nonatomic) const char *attributesCString;
@end
@implementation PropertyModel
@synthesize name, attributesCString;
@end


#pragma mark - ValueInjectorUtility
@implementation ValueInjectorUtility
@synthesize dateFormatter = _dateFormatter;
static ValueInjectorUtility *_instance;
+ (id)sharedInstance
{
    @synchronized (_instance) {
        if (_instance == nil) {
            _instance = [self new];
#if __has_feature(objc_arc)
            _instance.dateFormatter = [NSDateFormatter new];
#else
            _instance.dateFormatter = [[NSDateFormatter new] autorelease];
#endif
            [_instance.dateFormatter setDateFormat:ValueInjectorTimeFormate];
        }
        return _instance;
    }
}
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
        model.attributesCString = property_getAttributes(property);
        [result addObject:model];
    }
    free(properties);
    
    // scan super class
    Class superCls = class_getSuperclass([cls class]);
    if ([superCls class] != [NSObject class]) {
        [result addObjectsFromArray:[self getPropertyList:superCls]];
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
    if ([self isKindOfClass:[NSMutableArray class]]) {
        for (id item in (NSArray *)object) {
#if __has_feature(objc_arc)
            id instance = [cls new];
#else
            id instance = [[cls new] autorelease];
#endif
            [instance injectCoreFromObject:item arrayClass:nil];
            [(NSMutableArray *)self addObject:instance];
        }
        return self;
    }
    else {
        return [self injectCoreFromObject:object arrayClass:cls];
    }
}
- (id)injectCoreFromObject:(NSObject *)object arrayClass:(__unsafe_unretained Class)cls
{
    // list properties of custom class and inject value
    NSArray *properties = [[ValueInjectorUtility sharedInstance] getPropertyList:[self class]];
    
    // inject target is custom class
    for (unsigned int index = 0; index < [properties count]; index++) {
        PropertyModel *property = [properties objectAtIndex:index];
        
        id value = [object valueForKey:property.name];
        
        if (value == nil || [value isKindOfClass:[NSNull class]])
            continue;
        
        const char *start = strstr(property.attributesCString, "T@\"");
        if (start != 0x00) {
            // the type of peoperty is class
            char *attcontent;
            attcontent = malloc(strlen(start) + 1);
            strcpy(attcontent, start + 3);
            unsigned long endIndex = strcspn(attcontent, "\"");
            // get class type name from attributes of property
            char *classNameCString;
            classNameCString = malloc(endIndex + 1);
            strncpy(classNameCString, attcontent, endIndex);
            classNameCString[endIndex] = '\0';
            free(attcontent);
            
            // NSString
            if (strcmp(classNameCString, "NSString") == 0) {
                if ([value class] == [NSString class]) {
                    [self setValue:value forKey:property.name];
                }
                else {
                    [self setValue:[NSString stringWithFormat:@"%@", value] forKey:property.name];
                }
            }
            // NSNumber
            else if (strcmp(classNameCString, "NSNumber") == 0) {
                [self setValue:value forKey:property.name];
            }
            // NSDate
            else if (strcmp(classNameCString, "NSDate") == 0) {
                ValueInjectorUtility *viu = [ValueInjectorUtility sharedInstance];
                [self setValue:[viu.dateFormatter dateFromString:value] forKey:property.name];
            }
            // NSDictionary
            else if (strcmp(classNameCString, "NSDictionary") == 0) {
                // stop inject children propertis and reconstruct NSDictionary
                @try {
                    [self setValue:[NSDictionary dictionaryWithDictionary:value] forKey:property.name];
                }
                @catch (NSException *exception) {
                    [self setValue:value forKey:property.name];
                }
            }
            // NSArray
            else if (strcmp(classNameCString, "NSArray") == 0) {
                if (cls == nil) {
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
                        [model injectCoreFromObject:item arrayClass:nil];
                        // put model into result array
                        if (model == nil || [model isKindOfClass:[NSNull class]]) {
                            [result addObject:[NSNull null]];
                        }
                        else {
                            [result addObject:model];
                        }
                    }
                    // inject value to property of custom class
                    [self setValue:result forKey:property.name];
                }
            }
            // custom class
            else {
                Class cl = NSClassFromString([NSString stringWithCString:classNameCString encoding:NSUTF8StringEncoding]);
#if __has_feature(objc_arc)
                id model = [cl new];
#else
                id model = [[cl new] autorelease];
#endif
                [model injectCoreFromObject:value arrayClass:nil];
                [self setValue:model forKey:property.name];
            }
            free(classNameCString);
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
- (id)injectFromdotNetDictionary:(NSArray *)object
{
    for (NSDictionary *target in object) {
        NSString *targetName = [target objectForKey:@"Key"];
        objc_property_t property = class_getProperty([self class], [targetName cStringUsingEncoding:NSUTF8StringEncoding]);
        const char *attributes = property_getAttributes(property);
        
        // NSDate
        if (strcmp(attributes, "T@\"NSDate") == 0) {
            ValueInjectorUtility *viu = [ValueInjectorUtility sharedInstance];
            [self setValue:[viu.dateFormatter dateFromString:[target objectForKey:@"Value"]] forKey:targetName];
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
    NSArray *properties = [[ValueInjectorUtility sharedInstance] getPropertyList:[object class]];
    
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
            const char *start = strstr(property.attributesCString, "T@\"");
            if (start != 0x00) {
                char *attcontent;
                attcontent = malloc(strlen(start) + 1);
                strcpy(attcontent, start + 3);
                unsigned long endIndex = strcspn(attcontent, "\"");
                // get class type name from attributes of property
                char *classNameCString;
                classNameCString = malloc(endIndex + 1);
                strncpy(classNameCString, attcontent, endIndex);
                classNameCString[endIndex] = '\0';
                free(attcontent);
                
                if (strcmp(classNameCString, "NSString") == 0 ||
                    strcmp(classNameCString, "NSNumber") == 0) {
                    [content addObject:value];
                }
                else if (strcmp(classNameCString, "NSDictionary") == 0) {
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
                else if (strcmp(classNameCString, "NSArray") == 0) {
                    NSArray *source = value;
                    @try {
                        if ([source count] == 0) {
                            //array is empty
                            [content addObject:value];
                        }
                        else {
                            const char *arrayContent = class_getName([[source objectAtIndex:0] class]);
                            if (strcmp(arrayContent, "NSString") == 0 ||
                                strcmp(arrayContent, "NSNumber") == 0) {
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
                free(classNameCString);
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