//
//  TestClass.h
//  ValueInjectorDemo
//
//  Created by Kelp on 12/7/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestClass : NSObject

@property (nonatomic) BOOL boolData;
@property (nonatomic) int intData;
@property (nonatomic) uint uintData;
@property (nonatomic) long longData;
@property (nonatomic) unsigned long ulongData;
@property (nonatomic) double doubleData;
@property (strong, nonatomic) NSDecimalNumber *decimalNumber;
@property (strong, nonatomic) NSString *stringData;
@property (strong, nonatomic) NSDate *dateData;
@property (strong, nonatomic) NSData *dataData;
@property (strong, nonatomic) NSNumber *numberData;

@end
