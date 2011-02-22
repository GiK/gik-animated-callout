//
//  HotelDetailViewController.h
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Hotel;

@interface HotelDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {
	UITableView *table;
	Hotel *hotel;

@private
	NSArray *directions;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) Hotel *hotel;

@end
