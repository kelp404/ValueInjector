//
//  dotNetTestModel.h
//  ValueInjectorDemo
//
//  Created by Kelp Chen on 12/6/19.
//  Copyright (c) 2012年 kelpchen@accuvally.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dotNetTestModel : NSObject

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *Title;
@property (nonatomic) int CheckNum;
@property (nonatomic) int Total;
@property (nonatomic) NSString *SoldAmount;

@end
