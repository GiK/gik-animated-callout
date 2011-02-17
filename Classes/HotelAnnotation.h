//
//  HotelAnnotation.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKAnnotation.h"

@class Hotel;

@interface HotelAnnotation : GIKAnnotation {
	Hotel *hotel;	
}

@property (nonatomic, retain) Hotel *hotel;

@end
