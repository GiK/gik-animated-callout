//
//  GIKAnnotation.m
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKAnnotation.h"

@interface GIKAnnotation ()

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end


@implementation GIKAnnotation

@synthesize latitude, longitude, callout;

- (void)dealloc {
	[callout release];
	[super dealloc];
}

- (id)initWithLatitude:(CLLocationDegrees)theLatitude longitude:(CLLocationDegrees)theLongitude {
	if (!(self = [super init])) {
		return nil;
	}
	
	latitude = theLatitude;
	longitude = theLongitude;
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	return (CLLocationCoordinate2D){self.latitude, self.longitude};
}

- (void)setCoordinate:(CLLocationCoordinate2D)theCoordinate {
	self.latitude = theCoordinate.latitude;
	self.longitude = theCoordinate.longitude;
}

@end
