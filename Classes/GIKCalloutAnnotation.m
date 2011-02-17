//
//  GIKCallout.m
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKCalloutAnnotation.h"

@implementation GIKCalloutAnnotation

@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)theCoordinate {
	if (!(self = [super init])) {
		return nil;
	}
	
	coordinate = theCoordinate;
	return self;
}
@end
