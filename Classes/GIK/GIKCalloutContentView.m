//
//  GIKCalloutContentView.m
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKCalloutContentView.h"

#define INSET_TOP					4.0f
#define INSET_LEFT                  4.0f

#define DEFAULT_CONTENT_HEIGHT		35.0f
#define ACCESSORY_BUFFER			4.0f

#define RIGHT_ACCESSORY_SIZE		29.0f
#define RIGHT_ACCESSORY_INSET_TOP	4.0f

@interface GIKCalloutContentView ()

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIButton *rightAccessoryView;

@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, copy) NSString *textLabelText;
@end

@implementation GIKCalloutContentView
@synthesize mode;
@synthesize textLabel;
@synthesize rightAccessoryView;
@synthesize detailView;
@synthesize textLabelFrame;
@synthesize textLabelText;
@synthesize delegate;

- (void)dealloc {
	[textLabelText release];
	[textLabel release];
	[rightAccessoryView release];
	[detailView release];
    [super dealloc];
}

+ (GIKCalloutContentView *)viewWithLabelText:(NSString *)text {
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]];
	CGFloat contentWidth = INSET_LEFT + textSize.width + ACCESSORY_BUFFER + RIGHT_ACCESSORY_SIZE;
	
	// If the width is an odd number, the view may not be drawn on pixel boundaries.
	if (fmod(contentWidth, 2.0f) > 0) {
		contentWidth += 1;
	}
	
	CGRect contentFrame = CGRectMake(0.0f, 0.0f, contentWidth, DEFAULT_CONTENT_HEIGHT);
	return [[[self alloc] initWithFrame:contentFrame text:text textSize:textSize] autorelease];
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)theText textSize:(CGSize)theTextSize {
    if (!(self = [super initWithFrame:frame])) {
		return nil;
	}

	mode = GIKContentModeDefault;
	textLabelText = [theText copy];
	textLabelFrame = CGRectMake(INSET_LEFT, roundf(DEFAULT_CONTENT_HEIGHT/2 - theTextSize.height/2), theTextSize.width, theTextSize.height);
	
	[self setClipsToBounds:YES];
	
	[self addSubview:self.textLabel];
	[self addSubview:self.rightAccessoryView];
	return self;
}

- (UILabel *)textLabel {
	if (textLabel == nil) {
		textLabel = [[UILabel alloc] init];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
		textLabel.textColor = [UIColor whiteColor];
		textLabel.shadowColor = [UIColor blackColor];
		textLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
	}
	textLabel.text = self.textLabelText;
	return textLabel;
}

- (UIButton *)rightAccessoryView {
	if (rightAccessoryView == nil) {
		rightAccessoryView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightAccessoryView.enabled = YES;
		[rightAccessoryView setImage:[UIImage imageNamed:@"Button_DisclosureAccessory.png"] forState:UIControlStateNormal];
		[rightAccessoryView addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	}
	return rightAccessoryView;
}

- (void)setDetailView:(UIView *)theDetailView {
	if (detailView != theDetailView) {
		[detailView removeFromSuperview];
		[detailView release];
		detailView = [theDetailView retain];
		
		detailView.hidden = YES;
		CGRect detailFrame = detailView.frame;
		detailFrame.origin = CGPointMake(0.0f, 40.0f);
		detailView.frame = detailFrame;
		
		[self addSubview:detailView];
	}
}

- (IBAction)accessoryButtonTapped:(id)sender {
	[self.delegate accessoryButtonTapped];
}

- (void)layoutSubviews {
	CGRect accessoryFrame = CGRectMake(self.bounds.size.width - RIGHT_ACCESSORY_SIZE, RIGHT_ACCESSORY_INSET_TOP, RIGHT_ACCESSORY_SIZE, RIGHT_ACCESSORY_SIZE);
	
	switch (mode) {
		case GIKContentModeDefault:
			self.textLabel.frame = self.textLabelFrame;
			self.rightAccessoryView.frame = accessoryFrame;
			self.detailView.hidden = YES;
			break;
			
		case GIKContentModeDetail:
			self.textLabel.center = CGPointMake(roundf(self.bounds.size.width/2), self.textLabel.center.y);
			self.rightAccessoryView.frame = accessoryFrame;
			self.rightAccessoryView.alpha = 0.0f;
			break;
			
		default:
			break;
	}
}

- (void)disableMapSelections {
	[self.delegate disableMapSelections];
}

@end
