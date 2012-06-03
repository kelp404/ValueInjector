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

- (void)testInjectFromObject
{
    NSString *json = @"{\"name\":\"台北車站\",\"Status\":{\"code\":200,\"request\":\"geocode\"},\"Placemark\":[{\"id\":\"p1\",\"address\":\"100台灣台北市中正區台北火車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"台北火車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0492730,\"south\":25.0465750,\"east\":121.5184300,\"west\":121.5157320}},\"Point\":{\"coordinates\":[121.5170810,25.0479240,0]}},{\"id\":\"p2\",\"address\":\"100台灣台北市中正區捷運台北車站\",\"AddressDetails\":{\"Accuracy\":9,\"AddressLine\":[\"捷運台北車站\"]},\"ExtendedData\":{\"LatLonBox\":{\"north\":25.0476040,\"south\":25.0449060,\"east\":121.5188810,\"west\":121.5161830}},\"Point\":{\"coordinates\":[121.5175320,25.0462550,0]}}]}";
    // parsing json with JSONKit() https://github.com/johnezang/JSONKit
    NSDictionary *geo = [json objectFromJSONString];
    // instance strong typing
    GoogleGeoModel *model = [GoogleGeoModel new];
    // convert weak typing to strong typing
    [model injectFromObject:geo];
    
    STAssertEqualObjects(model.name, @"台北車站", nil);
    
    GoogleGeoPlacemark *placemark1 = ((GoogleGeoPlacemark *)[model.Placemark objectAtIndex:0]);
    STAssertEqualObjects(placemark1.id, @"p1", nil);
    STAssertEqualObjects(placemark1.address, @"100台灣台北市中正區台北火車站", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%i", placemark1.AddressDetails.Accuracy]), @"9", nil);
    STAssertEqualObjects([placemark1.AddressDetails.AddressLine objectAtIndex:0], @"台北火車站", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%@", [placemark1.ExtendedData.LatLonBox valueForKey:@"east"]]), @"121.51843", nil);
    STAssertEqualObjects(([NSString stringWithFormat:@"%@", [placemark1.Point.coordinates objectAtIndex:0]]), @"121.517081", nil);
}

- (void)testInitWithObject
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

@end
