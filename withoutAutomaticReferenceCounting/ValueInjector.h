//
//  ValueInjector   1.0 without Objective-C Automatic Reference Counting
//
//  Created by Kelp on 12/5/6.
//  Copyright (c) 2012年 Kelp http://kelp.phate.org/
//  MIT License
//
//  1.0
//      Inject value from NSDictionary to custom class
//      NSObject (ValueInjector)
//      - (id)injectFromObject:(NSObject *)object;
//
//      init NSDictionary with custom class
//      NSDictionary (ValueInjector)
//      - (id)initWithObject:(NSObject *)object;
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface NSObject (ValueInjector)
- (id)injectFromObject:(NSObject *)object;
@end

@interface NSDictionary (ValueInjector)
- (id)initWithObject:(NSObject *)object;
@end