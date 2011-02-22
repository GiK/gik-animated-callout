//
//  GIKCalloutView.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

//  Subclass of MKAnnotationView which holds our custom view.
//  Inspired by the work of James Rantanen and his custom map annotations:
//  http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-1/

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GIKCalloutContentView.h"

@class GIKAnnotation;

typedef enum {
	CalloutModeDefault,
	CalloutModeDetail
} CalloutMode;

typedef enum {
	ArrowLeft,
	ArrowRight,
	ArrowDown
} ArrowOrientation;

typedef enum {
	LeftBias,
	RightBias
} CalloutBias;

@interface GIKCalloutView : MKAnnotationView <GIKCalloutContentViewDelegate, UIGestureRecognizerDelegate> {	
	MKAnnotationView *parentAnnotationView; // The subclass of GIKAnnotationView (or GIKPinAnnotationView) which was selected from the map.
	MKMapView *mapView;
	UIView *calloutContentView;				// Container view
	
@private
	UIImageView *topLeft, *topMiddle, *middleMiddle, *topRight;
	UIImageView *leftAboveArrow, *leftBelowArrow, *rightAboveArrow, *rightBelowArrow;
	UIImageView *bottomLeft, *bottomLeftOfArrow, *bottomRightOfArrow, *bottomRight;
	UIImageView *leftArrow, *rightArrow, *bottomArrow;
	
	CGFloat sideArrowVerticalOffset;		// Vertical position of the side arrows on the expanded callout.
	CGFloat bottomArrowHorizontalOffset;	// Horizontal position of the down arrow on the callout bubble.
	CGPoint parentOrigin;					// Origin of parent annotation view (GIKPinAnnotationView or GIKAnnotationView)
	
	NSUInteger horizontalAnimationTick;		// Used by CADisplayLink selector to choose subimage for bottom arrow animation.
	NSUInteger verticalAnimationTick;		// Used by CADisplayLink selector to choose subimage for side arrow animation.
	
	CADisplayLink *animationDisplayLink;	// Added to the animation's runloop to control the animation of arrows as the callout expands.
	
	CalloutMode calloutMode;
	CalloutBias calloutBias;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIView *calloutContentView;

@end
