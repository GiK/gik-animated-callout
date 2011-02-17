//
//  GIKMapViewController.h
//  AnimatedCallout
//
//  Created by Gordon on 2/17/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol GIKCalloutDetailDataSource;

@interface GIKMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *mapView;
	MKAnnotationView *selectedAnnotationView;
	UIViewController *calloutDetailController;
	
	id<GIKCalloutDetailDataSource> detailDataSource;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, retain) UIViewController *calloutDetailController;
@property (nonatomic, assign) id<GIKCalloutDetailDataSource> detailDataSource;

@end

// Protocol that requests data to be displayed in the detail view of GIKCalloutContentView.
@protocol GIKCalloutDetailDataSource <NSObject>
- (void)detailController:(UIViewController *)detailController detailForAnnotation:(id)annotation;
@end