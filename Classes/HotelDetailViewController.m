    //
//  HotelDetailViewController.m
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "HotelDetailViewController.h"
#import "Hotel.h"

typedef enum {
	kDirections,
	kPhone,
	kURL,
	kAddress,
	NUMBER_OF_SECTIONS
} TableSections;

@interface HotelDetailViewController ()
@property (nonatomic, readonly) NSArray *directions;
@end

@implementation HotelDetailViewController

@synthesize table, hotel;
@synthesize directions;

- (void)dealloc {
	[directions release];
	[table release];
	[hotel release];
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		return nil;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.table.backgroundColor = [UIColor clearColor];
	UIImage *backgroundImage = [[UIImage imageNamed:@"CalloutTableBackground.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:6];
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	backgroundImageView.frame = self.view.bounds;
	self.table.backgroundView = backgroundImageView;
	[backgroundImageView release];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.table = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kAddress) {
		return 80.0f;
	}
	return 44.0f;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *kDirectionCellIdentifier = @"DirectionCellIdentifier";
	static NSString *kOtherCellIdentifier = @"OtherCellIdentifier";
	
	NSString *workingCellIdentifier = (indexPath.section == kDirections) ? kDirectionCellIdentifier : kOtherCellIdentifier;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:workingCellIdentifier];
	if (cell == nil) {
		if ([workingCellIdentifier isEqualToString:kDirectionCellIdentifier]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:workingCellIdentifier] autorelease];			
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:workingCellIdentifier] autorelease];
		}
	}
	
	switch (indexPath.section) {
		case kDirections:
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.text = [self.directions objectAtIndex:indexPath.row];
			cell.textLabel.textColor = [UIColor colorWithRed:82.0f/255.0f green:102.0f/255.0f blue:145.0f/255.0f alpha:1.0f];
			break;
		case kPhone:
			cell.textLabel.text = @"phone";
			cell.detailTextLabel.text = self.hotel.phone;
			break;
		case kURL:
			cell.textLabel.text = @"home page";
			cell.detailTextLabel.text = self.hotel.url;
			break;
		case kAddress:
			cell.textLabel.text = @"address";
			
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.detailTextLabel.numberOfLines = 4;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@ %@\n%@",
										 self.hotel.street,
										 self.hotel.city,
										 self.hotel.state,
										 self.hotel.zip];
			break;
		default:
			break;
	}
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	switch (section) {
		case kDirections:
			rows = [self.directions count];
			break;
		case kPhone:
		case kURL:
		case kAddress:
			rows = 1;
			break;
		default:
			break;
	}
	return rows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.table.superview performSelector:@selector(disableMapSelections)];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kURL) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.hotel.url]];
	}
}


#pragma mark -
#pragma mark Accessors

- (void)setHotel:(Hotel *)newHotel {
	if (hotel != newHotel) {
		[hotel release];
		hotel = [newHotel retain];
	}
	[self.table reloadData];
}

- (NSArray *)directions {
	if (directions == nil) {
		directions = [[NSArray alloc] initWithObjects:@"Directions To Here", @"Directions From Here", nil];
	}
	return directions;
}

@end
