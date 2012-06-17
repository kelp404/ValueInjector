/*
  ValueInjector   1.0.3

  Created by Kelp on 12/5/6.
  Copyright (c) 2012 Kelp http://kelp.phate.org/
  MIT License

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


@interface NSObject (ValueInjector)
- (id)injectFromObject:(NSObject *)object;
@end

@interface NSDictionary (ValueInjector)
- (id)initWithObject:(NSObject *)object;
@end