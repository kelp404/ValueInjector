//
//  GoogleGeoModel.h
//

#import <Foundation/Foundation.h>

@interface GoogleGeoPoint : NSObject
@property (nonatomic, retain) NSArray *coordinates;
@end

@interface GoogleGeoExtendedData : NSObject
@property (nonatomic, retain) NSDictionary *LatLonBox;
@end

@interface GoogleGeoAddressDetails : NSObject
@property (nonatomic) int Accuracy;
@property (nonatomic, retain) NSArray *AddressLine;
@end

@interface GoogleGeoPlacemark : NSObject
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) GoogleGeoAddressDetails *AddressDetails;
@property (nonatomic, retain) GoogleGeoExtendedData *ExtendedData;
@property (nonatomic, retain) GoogleGeoPoint *Point;
@end

@interface GoogleGeoStatus : NSObject
@property (nonatomic) int code;
@property (nonatomic, retain) NSString *request;
@end


@interface GoogleGeoModel : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) GoogleGeoStatus *Status;
@property (nonatomic, retain) NSArray *Placemark;
@end