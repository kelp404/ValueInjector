//
//  ValueInjectorDemoTests.m
//  ValueInjectorDemoTests
//
//  Created by Kelp on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ValueInjectorDemoTests.h"

@implementation ValueInjectorDemoTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test0InjectFromObject
{
    NSString *json = @"{\"name\":\"台北車站\",\"Status\":{\"code\":200,\"request\":\"geocode\"},\"Placemark\":[{\"id\":\"p1\",\"address\":\"100台灣台北市中正區台北火車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"台北火車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0492730,\"south\":25.0465750,\"east\":121.5184300,\"west\":121.5157320}},\"Point\":{\"coordinates\":[121.5170810,25.0479240,0]}},{\"id\":\"p2\",\"address\":\"100台灣台北市中正區捷運台北車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"捷運台北車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0476040,\"south\":25.0449060,\"east\":121.5188810,\"west\":121.5161830}},\"Point\":{\"coordinates\":[121.5175320,25.0462550,0]}}]}";
    // parsing json with JSONKit() https://github.com/johnezang/JSONKit
    NSDictionary *geo = [json objectFromJSONString];
    // instance strong typing
    GoogleGeoModel *model = [GoogleGeoModel new];
    // convert weak typing to strong typing
    [model injectFromObject:geo arrayClass:[GoogleGeoPlacemark class]];
    
    STAssertEqualObjects(model.name, @"台北車站", nil);
    
    GoogleGeoPlacemark *placemark1 = ((GoogleGeoPlacemark *)[model.Placemark objectAtIndex:0]);
    STAssertEqualObjects(placemark1.id, @"p1", nil);
    STAssertEqualObjects(placemark1.address, @"100台灣台北市中正區台北火車站", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%i", placemark1.AddressDetails.Accuracy]), @"9", nil);
    STAssertEqualObjects([placemark1.AddressDetails.AddressLine objectAtIndex:0], @"台北火車站", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%@", [placemark1.ExtendedData.LatLonBox valueForKey:@"east"]]), @"121.51843", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%@", [placemark1.Point.coordinates objectAtIndex:0]]), @"121.517081", nil);
}

- (void)test1InitWithObject
{
    NSString *json = @"{\"name\":\"台北車站\",\"Status\":{\"code\":200,\"request\":\"geocode\"},\"Placemark\":[{\"id\":\"p1\",\"address\":\"100台灣台北市中正區台北火車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"台北火車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0492730,\"south\":25.0465750,\"east\":121.5184300,\"west\":121.5157320}},\"Point\":{\"coordinates\":[121.5170810,25.0479240,0]}},{\"id\":\"p2\",\"address\":\"100台灣台北市中正區捷運台北車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"捷運台北車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0476040,\"south\":25.0449060,\"east\":121.5188810,\"west\":121.5161830}},\"Point\":{\"coordinates\":[121.5175320,25.0462550,0]}}]}";
    NSDictionary *geo = [json objectFromJSONString];
    GoogleGeoModel *model = [GoogleGeoModel new];
    // convert weak typing to strong typing
    [model injectFromObject:geo];
    
    // convert strong typing to weak typing
    NSDictionary *dic = [[NSDictionary alloc] initWithObject:model];
    NSString *dicString = [NSString stringWithFormat:@"%@", dic];
    NSString *geoString = [NSString stringWithFormat:@"%@", geo];
    if (![dicString isEqualToString:geoString]) {
        STFail(@"dicString should be equal to geoString");
    }
}

- (void)test2InjectFromdotNetDictionary
{
    NSString *json = @"[{\"Key\":\"Id\",\"Value\":\"114077570386978\"},{\"Key\":\"Title\",\"Value\":\"Kelp-test01\"},{\"Key\":\"CheckNum\",\"Value\":0},{\"Key\":\"Total\",\"Value\":2},{\"Key\":\"SoldAmount\",\"Value\":\"NT$0\"}]";
    NSArray *weak = [json objectFromJSONString];
    dotNetTestModel *model = [dotNetTestModel new];
    // convert weak typing to strong typing
    [model injectFromdotNetDictionary:weak];
    
    STAssertEqualObjects(model.Id, @"114077570386978", nil);
    STAssertEqualObjects(model.Title, @"Kelp-test01", nil);
    if (model.CheckNum != 0) {
        STFail(@"InjectFromdotNewDictionary Error");
    }
    if (model.Total != 2) {
        STFail(@"InjectFromdotNewDictionary Error");
    }
    STAssertEqualObjects(model.SoldAmount, @"NT$0", nil);
}

- (void)test3TestClass
{
    TestClass *cls = [TestClass new];
    cls.intData = 10;
    cls.uintData = 20000;
    cls.doubleData = 3.1415926;
    cls.dataData = [@"おはよう" dataUsingEncoding:NSUTF8StringEncoding];
    cls.decimalNumber = [[NSDecimalNumber alloc] initWithString:@"2000000"];
    cls.dateData = [NSDate date];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObject:cls];
    TestClass *cls2 = [TestClass new];
    [cls2 injectFromObject:dic];
    
    int intT = 10;
    if (intT != cls2.intData) {
        STFail(@"Error");
    }
    uint uintT = 20000;
    if (uintT != cls2.uintData) {
        STFail(@"Error");
    }
    double doubleT = 3.1415926;
    if (doubleT != cls2.doubleData) {
        STFail(@"Error");
    }
    NSData *dataT = [@"おはよう" dataUsingEncoding:NSUTF8StringEncoding];
    if (![dataT isEqualToData:cls2.dataData]) {
        STFail(@"Error");
    }
    NSDecimalNumber *decimal = [[NSDecimalNumber alloc] initWithString:@"2000000"];
    if (![decimal isEqualToValue:cls2.decimalNumber]) {
        STFail(@"Error");
    }
    if (![cls2.dateData isEqualToDate:cls.dateData]) {
        STFail(@"Error");
    }
}

@end
