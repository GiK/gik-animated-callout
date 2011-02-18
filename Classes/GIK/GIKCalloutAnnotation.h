//
//  GIKCallout.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

//  MKAnnotation object which is used to anchor the custom annotation view (GIKCalloutView) at the same coordinate as a selected pin.

#import <MapKit/MapKit.h>

@interface GIKCalloutAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)theCoordinate;

@end
