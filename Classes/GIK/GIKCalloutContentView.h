//
//  GIKCalloutContentView.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	GIKContentModeDefault,
	GIKContentModeDetail
} GIKContentMode;

@protocol GIKCalloutContentViewDelegate;

@interface GIKCalloutContentView : UIView {
	GIKContentMode mode;
	UIView *detailView;
	id<GIKCalloutContentViewDelegate> delegate;
	
@private
	UILabel *textLabel;
	UIButton *rightAccessoryView;
	CGRect textLabelFrame;
	NSString *textLabelText;
}

@property (nonatomic, assign) GIKContentMode mode;
@property (nonatomic, retain) UIView *detailView;
@property (nonatomic, assign) id<GIKCalloutContentViewDelegate> delegate;

+ (GIKCalloutContentView *)viewWithLabelText:(NSString *)text;
- (id)initWithFrame:(CGRect)frame text:(NSString *)theText textSize:(CGSize)theTextSize;
- (void)disableMapSelections;
@end


@protocol GIKCalloutContentViewDelegate <NSObject>
- (void)accessoryButtonTapped;
- (void)disableMapSelections;
@end