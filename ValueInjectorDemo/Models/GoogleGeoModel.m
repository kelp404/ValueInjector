//
//  GoogleGeoModel.m
//

#import "GoogleGeoModel.h"

@implementation GoogleGeoPoint
@synthesize coordinates;
@end

@implementation GoogleGeoExtendedData
@synthesize LatLonBox;
@end

@implementation GoogleGeoModel
@synthesize name, Status, Placemark;
@end

@implementation GoogleGeoStatus
@synthesize code, request;
@end

@implementation GoogleGeoAddressDetails
@synthesize Accuracy, AddressLine;
@end

@implementation GoogleGeoPlacemark
@synthesize id, address, AddressDetails, ExtendedData, Point;
@end