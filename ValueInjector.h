//
//  ValueInjector   1.0.1
//
//  Created by Kelp on 12/5/6.
//  Copyright (c) 2012 Kelp http://kelp.phate.org/
//  MIT License
//
//  1.0.1   2012/5/9
//      add ARC version
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