//
//  AnimatedCalloutViewController.m
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "MapViewController.h"
#import "Hotel.h"
#import "HotelAnnotation.h"
#import "HotelDetailViewController.h"

@interface MapViewController ()
@property (nonatomic, retain) NSArray *hotels;
- (void)showAnnotations;
@end


@implementation MapViewController

@synthesize hotels;

- (void)dealloc {
	[hotels release];
	[super dealloc];
}

- (id)init {
	if (!(self = [super initWithNibName:@"GIKMapView" bundle:nil])) {
		return nil;
	}
	return self;
}

#pragma mark -
#pragma mark View management

- (void)viewDidLoad {
    [super viewDidLoad];
	
	MKCoordinateRegion startupRegion;
	
	// Coordinates for part of downtown San Francisco - around Moscone West, no less.
	startupRegion.center = CLLocationCoordinate2DMake(37.785334, -122.406964);
	startupRegion.span = MKCoordinateSpanMake(0.003515, 0.007129);
	[self.mapView setRegion:startupRegion animated:YES];
	[self.mapView setShowsUserLocation:NO];
	
	// Our superclass needs access to the data for the custom callout without knowing implementation details.
	self.detailDataSource = self;
	
	HotelDetailViewController *controller = [[HotelDetailViewController alloc] initWithNibName:@"HotelDetailTableView" bundle:nil];
	self.calloutDetailController = controller;
	[controller release];
	
	[self showAnnotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return YES;
}


- (void)showAnnotations {
	NSMutableArray *hotelAnnotations = [NSMutableArray arrayWithCapacity:4];
	for (NSDictionary *hotel in self.hotels) {
		
		Hotel *theHotel = [[Hotel alloc] init];
		theHotel.name = [hotel objectForKey:@"name"];
		theHotel.street = [hotel objectForKey:@"street"];
		theHotel.city = [hotel objectForKey:@"city"];
		theHotel.state = [hotel objectForKey:@"state"];
		theHotel.zip = [hotel objectForKey:@"zip"];
		theHotel.phone = [hotel objectForKey:@"phone"];
		theHotel.url = [hotel objectForKey:@"url"];
		theHotel.latitude = [[hotel objectForKey:@"latitude"] doubleValue];
		theHotel.longitude = [[hotel objectForKey:@"longitude"] doubleValue];
		
		HotelAnnotation *annotation = [[HotelAnnotation alloc] initWithLatitude:theHotel.latitude longitude:theHotel.longitude];
		annotation.hotel = theHotel;
		
		[hotelAnnotations addObject:annotation];
		[annotation release];
		[theHotel release];
		
	}
	
	[self.mapView addAnnotations:hotelAnnotations];
}


#pragma mark -
#pragma mark GIKCalloutDetailDataSource

// Data object for the detail view of the callout.
- (void)detailController:(UIViewController *)detailController detailForAnnotation:(id)annotation {
	[(HotelDetailViewController *)detailController setHotel:[(HotelAnnotation *)annotation hotel]];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark Accessors

- (NSArray *)hotels {
	if (hotels == nil) {
		hotels = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Hotels" ofType:@"plist"]];
	}
	return hotels;
}

@end
