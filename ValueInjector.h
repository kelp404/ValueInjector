/*
  ValueInjector   1.0.7

  Created by Kelp on 12/5/6.
  Copyright (c) 2012 Kelp http://kelp.phate.org/
  MIT License

 1.0.7      2012*07*12
    performance optimization: Upgrade 70％
 
 1.0.6      2012-06-19
    new message injectFromdotNewDictionary
 
 1.0.5      2012-06-18
    ValueInjector supported NSDate
 
 1.0.4      2012-06-17
    change the way to instance typing in NSArray
 
 1.0.3      2012-06-17
    fixed bug: could not get property with extended class
 
 1.0.2      2012-06-03
    replace "[[class alloc] init]" to "[class new]"
 
 1.0.1     2012-05-09
    add ARC version

 1.0
    Inject value from NSDictionary to custom class
    NSObject (ValueInjector)
    - (id)injectFromObject:(NSObject *)object;

    init NSDictionary with custom class
    NSDictionary (ValueInjector)
    - (id)initWithObject:(NSObject *)object;
*/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#define ValueInjectorTimeFormate @"yyyy/MM/dd HH:mm"

#pragma mark - ValueInjectorUtility
@interface ValueInjectorUtility : NSObject
+ (id)sharedInstance;
#if __has_feature(objc_arc)
@property (strong) NSDateFormatter *dateFormatter;
#else
@property (retain) NSDateFormatter *dateFormatter;
#endif
@end

@interface NSObject (ValueInjector)
- (id)injectFromObject:(NSObject *)object;
- (id)injectFromObject:(NSObject *)object arrayClass:(Class)cls;
- (id)injectFromdotNetDictionary:(NSArray *)object;
@end

@interface NSDictionary (ValueInjector)
- (id)initWithObject:(NSObject *)object;
@end