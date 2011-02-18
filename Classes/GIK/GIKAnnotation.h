//
//  GIKAnnotation.h
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <MapKit/MapKit.h>

@class GIKCalloutAnnotation;

@interface GIKAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	
	GIKCalloutAnnotation *callout;
}

@property (nonatomic, retain) GIKCalloutAnnotation *callout;

- (id)initWithLatitude:(CLLocationDegrees)theLatitude longitude:(CLLocationDegrees)theLongitude;
- (void)setCoordinate:(CLLocationCoordinate2D)theCoordinate;

@end
