    //
//  GIKMapViewController.m
//  AnimatedCallout
//
//  Created by Gordon on 2/17/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKMapViewController.h"
#import "GIKCalloutAnnotation.h"
#import "GIKCalloutView.h"
#import "GIKCalloutContentView.h"
#import "GIKAnnotation.h"
#import "GIKPinAnnotationView.h"

@implementation GIKMapViewController

@synthesize mapView, selectedAnnotationView, calloutDetailController, detailDataSource;

- (void)dealloc {
	[calloutDetailController release];
	[selectedAnnotationView release];
	mapView.delegate = nil;
	[mapView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		return nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark View management

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.mapView removeAnnotations:self.mapView.annotations];
	self.mapView.showsUserLocation = NO;
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.mapView = nil;
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[GIKAnnotation class]]) {
		GIKAnnotation *selectedAnnotation = (GIKAnnotation *)view.annotation;
		if ([mapView.annotations indexOfObject:selectedAnnotation.callout] != NSNotFound) {
			return;
		}
		
		GIKCalloutAnnotation *callout = [[GIKCalloutAnnotation alloc] initWithLocation:selectedAnnotation.coordinate];
		selectedAnnotation.callout = callout;
		[theMapView addAnnotation:callout];
		[callout release];
		
		self.selectedAnnotationView = view;
		[self.detailDataSource performSelector:@selector(detailController:detailForAnnotation:) 
									withObject:self.calloutDetailController 
									withObject:self.selectedAnnotationView.annotation];
	}
}

- (void)mapView:(MKMapView *)theMapView didDeselectAnnotationView:(MKAnnotationView *)view {
	// Only remove the custom annotation (GIKCalloutAnnotation) if the parent annotation view can be deselected (selectionEnabled = YES)
	if ([view.annotation isKindOfClass:[GIKAnnotation class]] && ((GIKPinAnnotationView *)view).selectionEnabled) {
		[theMapView removeAnnotation:[(GIKAnnotation *)view.annotation callout]];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *kGIKAnnotationID = @"GIKAnnotation";
	static NSString *kGIKCalloutID = @"GIKCallout";
	
	if ([annotation isKindOfClass:[GIKAnnotation class]]) {
		GIKPinAnnotationView *pinView = (GIKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kGIKAnnotationID];
		if (pinView == nil) {
			pinView = [[[GIKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kGIKAnnotationID] autorelease];
		}
		return pinView;
	}
	else if ([annotation isKindOfClass:[GIKCalloutAnnotation class]]) {
		GIKCalloutView *calloutView = (GIKCalloutView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kGIKCalloutID];
		if (calloutView == nil) {
			calloutView = [[[GIKCalloutView alloc] initWithAnnotation:annotation reuseIdentifier:kGIKCalloutID] autorelease];
		}
		
		calloutView.parentAnnotationView = self.selectedAnnotationView;
		calloutView.mapView = self.mapView;
		
		GIKCalloutContentView *calloutContentView = [GIKCalloutContentView viewWithLabelText:[(GIKAnnotation *)self.selectedAnnotationView.annotation title]];

		calloutContentView.delegate = calloutView;
		calloutContentView.detailView = self.calloutDetailController.view;
		[calloutView setCalloutContentView:calloutContentView];
		return calloutView;
	}
	return nil;
}
	
@end
