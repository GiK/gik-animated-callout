//
//  Hotel.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Hotel : NSObject {
	NSString *name;
	NSString *street;
	NSString *city;
	NSString *state;
	NSString *zip;
	NSString *phone;
	NSString *url;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end
