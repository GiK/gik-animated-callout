//
//  Hotel.m
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "Hotel.h"


@implementation Hotel

@synthesize name, street, city, state, zip, phone, url;
@synthesize latitude, longitude;

- (void)dealloc {
	[name release];
	[street release];
	[city release];
	[state release];
	[zip release];
	[phone release];
	[url release];
	[super dealloc];
}

@end
