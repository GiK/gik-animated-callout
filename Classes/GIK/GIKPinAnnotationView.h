//
//  GIKPinAnnotationView.h
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface GIKPinAnnotationView : MKPinAnnotationView {
	BOOL selectionEnabled; // State flag to allow/prevent the callout's parent annotation view from being deselected.
}

@property (nonatomic, assign, getter=isSelectionEnabled) BOOL selectionEnabled;

@end
