//
//  GIKCalloutView.m
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKCalloutView.h"
#import "GIKCalloutContentView.h"
#import "GIKAnnotation.h"
#import "GIKAnnotationView.h"

#import <QuartzCore/QuartzCore.h>


#define BOTTOM_ARROW_WIDTH				35.0f
#define BOTTOM_ARROW_HEIGHT				45.0f
#define BOTTOM_ARROW_CENTER				18.0f

#define SIDE_ARROW_WIDTH				28.0f
#define SIDE_ARROW_HEIGHT				35.0f
#define SIDE_ARROW_CENTER				18.0f
#define SIDE_ARROW_ANNOTATION_OFFSET	9.0f

#define SIDE_WIDTH						15.0f
#define SIDE_INSET						5.0f
#define CONTENT_HORIZONTAL_INSET		13.0f
#define CONTENT_VERTICAL_INSET			4.0f

#define CONTENT_VIEW_ARROW_INSET		26.0f

#define TOP_HEIGHT						24.0f
#define BOTTOM_HEIGHT					32.0f
#define BOTTOM_INSET					5.0f

#define CALLOUT_HEIGHT					70.0f
#define CENTER_OFFSET_VERTICAL			-59.0f

#define ARROW_ANIMATION_FRAMES			15


@interface GIKCalloutView ()

@property (nonatomic, readonly) UIImageView *topLeft, *topMiddle, *middleMiddle, *topRight;
@property (nonatomic, readonly) UIImageView *leftAboveArrow, *leftBelowArrow, *rightAboveArrow, *rightBelowArrow;
@property (nonatomic, readonly) UIImageView *bottomLeft, *bottomLeftOfArrow, *bottomRightOfArrow, *bottomRight;
@property (nonatomic, retain) UIImageView *leftArrow, *rightArrow, *bottomArrow;

@property (nonatomic, assign) CGFloat sideArrowVerticalOffset;
@property (nonatomic, assign) CGFloat bottomArrowHorizontalOffset;
@property (nonatomic, assign) CGPoint parentOrigin;

@property (nonatomic, assign) NSUInteger horizontalAnimationTick;
@property (nonatomic, assign) NSUInteger verticalAnimationTick;

@property (nonatomic, retain) CADisplayLink *animationDisplayLink;

@property (nonatomic, assign) CalloutBias calloutBias;
@property (nonatomic, assign) CalloutMode calloutMode;

- (UIImage *)arrowForFrame:(NSUInteger)frameNumber orientation:(ArrowOrientation)orientation;
- (void)displayDefaultCallout;
- (void)disableSiblingAnnotations;
- (void)disableMapSelections;

@end


@implementation GIKCalloutView

@synthesize leftArrow, rightArrow, bottomArrow;
@synthesize sideArrowVerticalOffset;
@synthesize bottomArrowHorizontalOffset;
@synthesize parentAnnotationView;
@synthesize calloutContentView;
@synthesize mapView;
@synthesize parentOrigin;
@synthesize calloutBias;
@synthesize calloutMode;
@synthesize horizontalAnimationTick, verticalAnimationTick;
@synthesize animationDisplayLink;


- (void)dealloc {
	[animationDisplayLink invalidate];
	[animationDisplayLink release];
	mapView.delegate = nil;
	[mapView release];
	[calloutContentView release];
	[parentAnnotationView release];
	[topLeft release];
	[topMiddle release];
	[middleMiddle release];
	[topRight release];
	[leftAboveArrow release];
	[leftBelowArrow release];
	[rightAboveArrow release];
	[rightBelowArrow release];
	[leftArrow release];
	[rightArrow release];
	[bottomArrow release];
	[bottomLeft release];
	[bottomLeftOfArrow release];
	[bottomRightOfArrow release];
	[bottomRight release];
    [super dealloc];
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (!(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		return nil;
	}
	
	self.enabled = NO;
	self.backgroundColor = [UIColor clearColor];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
	panGestureRecognizer.cancelsTouchesInView = NO;
	panGestureRecognizer.delegate = self;
	[self addGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer release];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	tapGestureRecognizer.delaysTouchesEnded = YES;
	tapGestureRecognizer.delegate = self;
	[self addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFrom:)];
	longPressGestureRecognizer.cancelsTouchesInView = NO;
	longPressGestureRecognizer.delegate = self;
	[self addGestureRecognizer:longPressGestureRecognizer];
	[longPressGestureRecognizer release];
	
	
	return self;
}

- (void)didMoveToSuperview {
	[self.superview bringSubviewToFront:self];
	[self displayDefaultCallout];
}


#pragma mark -
#pragma mark Annotation setup

- (void)calculateOffsets {
	CGPoint mapCenter = [self.mapView convertPoint:CGPointMake(roundf(self.mapView.frame.size.width/2), roundf(self.mapView.frame.size.height/2)) toView:self.mapView.superview];
	int distanceFromCenter = mapCenter.x - self.parentOrigin.x;
	if (distanceFromCenter >= 0) {
		self.calloutBias = RightBias;
	}
	else {
		self.calloutBias = LeftBias;
	}
	
	CGFloat frameWidth = self.bounds.size.width;
	CGFloat arrowOffset = SIDE_WIDTH + SIDE_INSET + BOTTOM_ARROW_CENTER;
	CGFloat horizontalOffset;
	
	self.sideArrowVerticalOffset = [self convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview].y;
	
	
	if (fabs(distanceFromCenter) < (roundf(frameWidth/2) - arrowOffset)) {
		// The parent pin is close to the center, the callout bubble will be drawn centered on the map.
		// The down-arrow will be offset to the left or right of center, depending on the location of the pin.
		horizontalOffset = distanceFromCenter;
		self.bottomArrowHorizontalOffset = roundf(frameWidth/2) - distanceFromCenter - BOTTOM_ARROW_CENTER;
	}
	else {
		// The parent pin far enough to the left or right of center that the callout bubble can't be drawn in the center of the map.
		if (distanceFromCenter > 0) {
			// The down-arrow will be offset to the left of the bubble.
			horizontalOffset = roundf(frameWidth/2) - arrowOffset;
			self.bottomArrowHorizontalOffset = SIDE_WIDTH + SIDE_INSET;
		}
		else {
			// The down-arrow will be offset to the right of the bubble.
			horizontalOffset = - (roundf(frameWidth/2) - arrowOffset);
			self.bottomArrowHorizontalOffset = frameWidth - SIDE_WIDTH - SIDE_INSET - BOTTOM_ARROW_WIDTH;
		}
	}
	
	self.centerOffset = CGPointMake(horizontalOffset, CENTER_OFFSET_VERTICAL);
	
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
	[super setAnnotation:annotation];
	
	if (annotation != nil && self.parentAnnotationView != nil) {
		self.parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
		self.calloutMode = CalloutModeDefault;
		
		// Forces the arrow to be reset if it was cached.
		self.bottomArrow.image = [self arrowForFrame:0 orientation:ArrowDown];
		[self calculateOffsets];
	}
}


#pragma mark -
#pragma mark Callout layout & animation

// Grab an arrow subimage from the respective image atlases. 
- (UIImage *)arrowForFrame:(NSUInteger)frameNumber orientation:(ArrowOrientation)orientation {
	UIImage *arrowSourceImage = nil;
	CGSize subimageSize = CGSizeZero;
	CGPoint subimageOrigin = CGPointZero;
	CGRect subimageRect = CGRectZero;
	
	if (orientation == ArrowDown) {
		arrowSourceImage = [UIImage imageNamed:@"CalloutPopoverDownArrows.png"];
		subimageSize = CGSizeMake(BOTTOM_ARROW_WIDTH, BOTTOM_ARROW_HEIGHT);
		subimageOrigin = CGPointMake(subimageSize.width * frameNumber, 0);
	}
	else {
		arrowSourceImage = [UIImage imageNamed:@"CalloutPopoverLeftArrows.png"];
		subimageSize = CGSizeMake(SIDE_ARROW_WIDTH, SIDE_ARROW_HEIGHT);
		subimageOrigin = CGPointMake(0, subimageSize.height * (ARROW_ANIMATION_FRAMES - frameNumber -1));
	}
	
	subimageRect = (CGRect){subimageOrigin, subimageSize};
	
	CGImageRef cgArrow = CGImageCreateWithImageInRect(arrowSourceImage.CGImage, subimageRect);
	UIImage *theArrow = [UIImage imageWithCGImage:cgArrow];
	CFRelease(cgArrow);
	
	if (orientation == ArrowRight) {
		// Use UIImage scale property to flip the image horizontally.
		return [UIImage imageWithCGImage:theArrow.CGImage scale:theArrow.scale orientation:UIImageOrientationUpMirrored];
	}
	
	return theArrow;
}

- (CATransform3D)layerTransformForScale:(CGFloat)scale targetFrame:(CGRect)targetFrame {
	CGFloat horizontalDelta = targetFrame.size.width/2 - (self.bottomArrowHorizontalOffset + BOTTOM_ARROW_CENTER);
	CGFloat hotizontalScaleTransform = (horizontalDelta * scale) - horizontalDelta;
	
	CGFloat verticalDelta = roundf(targetFrame.size.height/2);
	CGFloat verticalScaleTransform = verticalDelta - (verticalDelta * scale);
	
	CGAffineTransform affineTransform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, hotizontalScaleTransform, verticalScaleTransform);
	return CATransform3DMakeAffineTransform(affineTransform);
}

// Popup animation for the selected callout.
- (void)displayDefaultCallout {
	CGRect targetFrame = self.bounds;
	self.layer.transform = [self layerTransformForScale:0.001f targetFrame:targetFrame];
	
	[UIView animateWithDuration:0.1 
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
					 animations:^{
						 self.layer.transform = [self layerTransformForScale:1.1f targetFrame:targetFrame];
					 } 
					 completion:^ (BOOL finished) {
						 [UIView animateWithDuration:0.1
											   delay:0
											 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
										  animations:^{
											  self.layer.transform = [self layerTransformForScale:0.95f targetFrame:targetFrame];
										  } 
										  completion:^ (BOOL finished) {
											  [UIView animateWithDuration:0.1
																	delay:0
																  options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
															   animations:^{
																   self.layer.transform = [self layerTransformForScale:1.0f targetFrame:targetFrame];
															   } 
															   completion:^ (BOOL finished) {
																   self.layer.transform = CATransform3DIdentity;
															   }
											   ];
										  }];
					 }
	 ];
}

- (void)updateBottomArrowImage {
	self.horizontalAnimationTick ++;
	if (self.horizontalAnimationTick < ARROW_ANIMATION_FRAMES) {
		self.bottomArrow.image = [self arrowForFrame:self.horizontalAnimationTick orientation:ArrowDown];
	}
}

- (void)updateSideArrowImage {
	self.verticalAnimationTick ++;
	if (self.verticalAnimationTick < ARROW_ANIMATION_FRAMES) {
		if (self.calloutBias == RightBias) {
			self.leftArrow.image = [self arrowForFrame:self.verticalAnimationTick orientation:ArrowLeft];
		}
		else {
			self.rightArrow.image = [self arrowForFrame:self.verticalAnimationTick orientation:ArrowRight];
		}
	}
}

- (void)displayDetailCallout {
	CGPoint newCalloutOrigin = CGPointZero;

	[(GIKCalloutContentView *)self.calloutContentView setMode:GIKContentModeDetail];
	
	CGRect contentFrame = [[(GIKCalloutContentView *)self.calloutContentView detailView] frame];
	CGSize newFrameSize = CGSizeMake(contentFrame.size.width + CONTENT_HORIZONTAL_INSET + CONTENT_HORIZONTAL_INSET, contentFrame.size.height);
	
	self.sideArrowVerticalOffset = roundf(newFrameSize.height/2) - self.frame.size.height - SIDE_ARROW_CENTER;
	
	if (self.calloutBias == LeftBias) {
		newCalloutOrigin = CGPointMake(self.parentAnnotationView.frame.origin.x - newFrameSize.width - 8.0f, self.frame.origin.y);
		self.leftArrow.image = [self arrowForFrame:0 orientation:ArrowLeft];
	}
	else if (self.calloutBias == RightBias) {
		newCalloutOrigin = CGPointMake(self.parentAnnotationView.frame.origin.x + 24.0f, self.frame.origin.y);
		self.rightArrow.image = [self arrowForFrame:0 orientation:ArrowRight];
	}
	
	CGRect newFrame = CGRectMake(newCalloutOrigin.x, newCalloutOrigin.y, newFrameSize.width, self.bounds.size.height);
	
	// When the CADisplayLink is added to the animation's run loop, it will draw a new image for the bottom arrow.
	// The default frame rate matches the device's refresh rate.
	self.animationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBottomArrowImage)];
	
	self.horizontalAnimationTick = 0;
	self.verticalAnimationTick = 0;
	
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews
					 animations:^{
						 //
						 // First, animate the width of the callout to match the detail view's width.
						 //
						 [self.animationDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
						 [self setFrame:newFrame];
					 }
					 completion:^ (BOOL finished) {
						 self.calloutMode = CalloutModeDetail;
						 [self.animationDisplayLink invalidate];
						 
						 // Draw a new image for the side arrow with every tick of the refresh rate.
						 self.animationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateSideArrowImage)];
						 CGRect expandedFrame = self.frame;
						 expandedFrame.size.height = self.bounds.size.height + newFrameSize.height + BOTTOM_INSET;
						 expandedFrame.origin.y = self.parentAnnotationView.frame.origin.y - roundf(expandedFrame.size.height/2) + SIDE_ARROW_CENTER;

						 // Re-set the centerOffset to the left or right side of the annotation pin.
						 // This ensures that the expanded callout will stay in position if the map's region property changes.
						 if (self.calloutBias == LeftBias) {
							 self.centerOffset = CGPointMake(-(roundf(expandedFrame.size.width/2)) - 16.0f, -16.0f);
						 }
						 else {
							 self.centerOffset = CGPointMake(roundf(expandedFrame.size.width/2) + 16.0f, -16.0f);
						 }
						 
						 [(GIKCalloutContentView *)self.calloutContentView detailView].hidden = NO;
						 
						 [UIView animateWithDuration:0.3
											   delay:0.0 
											 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews
										  animations:^{
											  //
											  // Second, animate the height of the callout to match the detail view's height.
											  //
											  [self.animationDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
											  [self setFrame:expandedFrame];
										  } 
										  completion:^ (BOOL finished) {
											  [self.animationDisplayLink invalidate];
										  }
						  ];							 
					 }
	 ];
}

- (void)layoutSubviews {
	
	// Here be madness!
	
	CGSize boundsSize = self.bounds.size;
	
	CGFloat middleHeight = boundsSize.height - TOP_HEIGHT - BOTTOM_ARROW_HEIGHT;
	CGFloat middleWidth = 0.0f;
	CGFloat heightOffset = 0.0f;
	CGFloat aboveArrowHeight, belowArrowHeight, arrowHeight;
	
	CGFloat leftOffset = 0.0f;
	CGFloat rightOffset = boundsSize.width - SIDE_WIDTH;
	
	// LeftBias		- the majority of the callout bubble is weighted to the left of the pin. Side arrow will be on the right of the callout.
	// RightBias	- the majority of the callout bubble is weighted to the right of the pin. Side arrow will be on the left of the callout.	
	if (self.calloutMode == CalloutModeDefault) {
		aboveArrowHeight = middleHeight;
		belowArrowHeight = 1.0f;
		arrowHeight = SIDE_ARROW_HEIGHT;
		self.leftArrow.hidden = YES;
		self.rightArrow.hidden = YES;
		self.leftBelowArrow.hidden = YES;
		self.rightBelowArrow.hidden = YES;
		middleWidth = boundsSize.width - SIDE_WIDTH - SIDE_WIDTH;
	}
	else {
		if (self.calloutBias == LeftBias) {
			rightOffset = boundsSize.width - SIDE_WIDTH;
		}
		self.leftArrow.hidden = NO;
		self.rightArrow.hidden = NO;
		self.leftBelowArrow.hidden = NO;
		self.rightBelowArrow.hidden = NO;
		
		aboveArrowHeight = [self convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview].y - TOP_HEIGHT - SIDE_ARROW_ANNOTATION_OFFSET;
		belowArrowHeight = boundsSize.height - TOP_HEIGHT - aboveArrowHeight - SIDE_ARROW_HEIGHT - BOTTOM_ARROW_HEIGHT;
		arrowHeight = SIDE_ARROW_HEIGHT;
		middleWidth = boundsSize.width - SIDE_WIDTH - SIDE_WIDTH;
	}
	
	
	// Top row.
	
	CGRect topLeftRect = CGRectMake(leftOffset, heightOffset, SIDE_WIDTH, TOP_HEIGHT);
	CGRect topMiddleRect = CGRectMake(topLeftRect.origin.x + topLeftRect.size.width, heightOffset, middleWidth, TOP_HEIGHT);
	CGRect topRightRect = CGRectMake(topMiddleRect.origin.x + topMiddleRect.size.width, heightOffset, SIDE_WIDTH, TOP_HEIGHT);
	
	// Middle row, including the areas above the left and right arrow.
	
	heightOffset += TOP_HEIGHT;
	
	CGRect leftAboveArrowRect = CGRectMake(leftOffset, heightOffset, SIDE_WIDTH, aboveArrowHeight);
	CGRect middleMiddleRect = CGRectMake(leftAboveArrowRect.origin.x + leftAboveArrowRect.size.width, TOP_HEIGHT, middleWidth, middleHeight);
	CGRect rightAboveArrowRect = CGRectMake(middleMiddleRect.origin.x + middleMiddleRect.size.width, heightOffset, SIDE_WIDTH, aboveArrowHeight);
	
	// Side arrows.
	
	heightOffset += leftAboveArrowRect.size.height;
	
	CGRect leftArrowRect = CGRectMake(leftOffset - (SIDE_ARROW_WIDTH - SIDE_WIDTH), heightOffset, SIDE_ARROW_WIDTH, arrowHeight);
	CGRect rightArrowRect = CGRectMake(rightAboveArrowRect.origin.x, heightOffset, SIDE_ARROW_WIDTH, arrowHeight);
	heightOffset += arrowHeight;
	
	// Areas below the arrow.
	
	CGRect leftBelowArrowRect = CGRectMake(leftOffset, heightOffset, SIDE_WIDTH, belowArrowHeight);
	CGRect rightBelowArrowRect = CGRectMake(middleMiddleRect.origin.x + middleMiddleRect.size.width, heightOffset, SIDE_WIDTH, belowArrowHeight);
	
	// Bottom row.
	
	CGFloat bottomBaseline = boundsSize.height - BOTTOM_ARROW_HEIGHT;
	
	CGRect bottomLeftRect = CGRectMake(leftOffset, bottomBaseline, SIDE_WIDTH, BOTTOM_HEIGHT);
	
	CGFloat leftOfArrowWidth = self.bottomArrowHorizontalOffset - SIDE_WIDTH;
	
	if (self.calloutMode == CalloutModeDetail && self.bottomArrowHorizontalOffset > 294.0f) {
		leftOfArrowWidth -= 40.0f;
	}
	
	CGRect bottomLeftOfArrowRect = CGRectMake(bottomLeftRect.origin.x + bottomLeftRect.size.width, bottomBaseline, leftOfArrowWidth, BOTTOM_HEIGHT);
	
	CGRect bottomArrowRect = CGRectMake(bottomLeftOfArrowRect.origin.x + bottomLeftOfArrowRect.size.width, bottomBaseline, BOTTOM_ARROW_WIDTH, BOTTOM_ARROW_HEIGHT);
	
	CGFloat rightOfArrowWidth = rightOffset - (bottomArrowRect.origin.x + bottomArrowRect.size.width);
	CGRect bottomRightOfArrowRect = CGRectMake(bottomArrowRect.origin.x + bottomArrowRect.size.width, bottomBaseline, rightOfArrowWidth, BOTTOM_HEIGHT);
	CGRect bottomRightRect = CGRectMake(bottomRightOfArrowRect.origin.x + bottomRightOfArrowRect.size.width, bottomBaseline, SIDE_WIDTH, BOTTOM_HEIGHT);
	
	self.topLeft.frame = topLeftRect;
	self.topMiddle.frame = topMiddleRect;
	self.topRight.frame = topRightRect;
	
	self.leftAboveArrow.frame = leftAboveArrowRect;
	self.rightAboveArrow.frame = rightAboveArrowRect;
	self.leftArrow.frame = leftArrowRect;
	self.rightArrow.frame = rightArrowRect;
	self.middleMiddle.frame = middleMiddleRect;
	self.leftBelowArrow.frame = leftBelowArrowRect;
	self.rightBelowArrow.frame = rightBelowArrowRect;
	
	self.bottomLeft.frame = bottomLeftRect;
	self.bottomLeftOfArrow.frame = bottomLeftOfArrowRect;
	self.bottomArrow.frame = bottomArrowRect;
	self.bottomRightOfArrow.frame = bottomRightOfArrowRect;
	self.bottomRight.frame = bottomRightRect;
	
	[self bringSubviewToFront:self.calloutContentView];
}

- (void)enableParentAnnotationSelection {
	GIKAnnotationView *parentView = (GIKAnnotationView *)self.parentAnnotationView;
	[self.mapView selectAnnotation:parentView.annotation animated:NO];
	parentView.selectionEnabled = YES;
}

- (void)disableParentAnnotationSelection {
	((GIKAnnotationView *)self.parentAnnotationView).selectionEnabled = NO;
}

- (void)enableSiblingAnnotationView:(UIView *)sibling {
	((MKAnnotationView *)sibling).enabled = YES;
}

- (void)disableSiblingAnnotations {
	[self performSelector:@selector(enableParentAnnotationSelection) withObject:nil afterDelay:1.0];
	[self.superview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([(UIView *)obj isKindOfClass:[MKAnnotationView class]] && obj != self.parentAnnotationView) {
			((MKAnnotationView *)obj).enabled = NO;
			[self performSelector:@selector(enableSiblingAnnotationView:) withObject:obj afterDelay:1.0];
		}
	}];
}

- (void)disableMapSelections {
	[self disableParentAnnotationSelection];
	[self disableSiblingAnnotations];
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate methods


- (void)handleTapFrom:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		// The calloutView may overlap other annotations - disable them temporarily so they can't be selected with the touch.
		[self disableMapSelections];
	}
}

- (void)handleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		// The calloutView may overlap other annotations - disable them temporarily so they can't be selected with the touch.
		[self disableMapSelections];
	}	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if (![[otherGestureRecognizer view] isDescendantOfView:self]) {
		
		// Setting the enabled property to NO while a gesture recognizer is currently
		// recognizing a gesture will cause it to transition to a cancelled state.
		otherGestureRecognizer.enabled = NO;
		
		// ... then re-enable so it can start receiving touches again. 
		// However, it'll ignore long gestures (pans, long presses, swipes) which are already in progress.
		otherGestureRecognizer.enabled = YES;
	}
	return YES;
}


#pragma mark -
#pragma mark GIKCalloutContentViewDelegate methods
	 
- (void)accessoryButtonTapped {	
	[self displayDetailCallout];
}


#pragma mark -
#pragma mark Accessors

- (void)setCalloutMode:(CalloutMode)newMode {
	calloutMode = newMode;
	[(GIKCalloutContentView *)self.calloutContentView setMode:newMode];
}


- (void)setCalloutContentView:(UIView *)theContentView {
	if (calloutContentView != theContentView) {
		[calloutContentView removeFromSuperview];
		[calloutContentView release];
		calloutContentView = [theContentView retain];
		
		self.frame = CGRectMake(0.0, 0.0, calloutContentView.frame.size.width + CONTENT_HORIZONTAL_INSET + CONTENT_HORIZONTAL_INSET, CALLOUT_HEIGHT);
		calloutContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		CGRect contentFrame = calloutContentView.frame;
		contentFrame.origin.x = CONTENT_HORIZONTAL_INSET;
		contentFrame.origin.y = CONTENT_VERTICAL_INSET;
		calloutContentView.frame = contentFrame;
		
		[self addSubview:calloutContentView];
	}
}


// Lazy accessors for the subviews that make the callout bubble.
- (UIImageView *)topLeft {
	if (topLeft == nil) {
		topLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverTopLeft.png"]];
		[self addSubview:topLeft];
	}
	return topLeft;
}

- (UIImageView *)topMiddle {
	if (topMiddle == nil) {
		topMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverTopMiddle.png"]];
		[self addSubview:topMiddle];
	}
	return topMiddle;
}

- (UIImageView *)middleMiddle {
	if (middleMiddle == nil) {
		middleMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverMiddleMiddle.png"]];
		[self addSubview:middleMiddle];
	}
	return middleMiddle;
}

- (UIImageView *)topRight {
	if (topRight == nil) {
		topRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverTopRight.png"]];
		[self addSubview:topRight];
	}
	return topRight;
}

- (UIImageView *)leftArrow {
	if (leftArrow == nil) {
		leftArrow = [[UIImageView alloc] initWithImage:[self arrowForFrame:0 orientation:ArrowLeft]];
		[self addSubview:leftArrow];
	}
	return leftArrow;
}

- (UIImageView *)rightArrow {
	if (rightArrow == nil) {
		rightArrow = [[UIImageView alloc] initWithImage:[self arrowForFrame:0 orientation:ArrowRight]];
		[self addSubview:rightArrow];
	}
	return rightArrow;
}

- (UIImageView *)bottomArrow {
	if (bottomArrow == nil) {
		bottomArrow = [[UIImageView alloc] initWithImage:[self arrowForFrame:0 orientation:ArrowDown]];
		[self addSubview:bottomArrow];
	}
	return bottomArrow;
}

- (UIImageView *)leftAboveArrow {
	if (leftAboveArrow == nil) {
		leftAboveArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverMiddleLeft.png"]];
		[self addSubview:leftAboveArrow];
	}
	return leftAboveArrow;
}

- (UIImageView *)leftBelowArrow {
	if (leftBelowArrow == nil) {
		leftBelowArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverMiddleLeft.png"]];
		[self addSubview:leftBelowArrow];
	}
	return leftBelowArrow;
}

- (UIImageView *)rightAboveArrow {
	if (rightAboveArrow == nil) {
		rightAboveArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverMiddleRight.png"]];
		[self addSubview:rightAboveArrow];
	}
	return rightAboveArrow;
}

- (UIImageView *)rightBelowArrow {
	if (rightBelowArrow == nil) {
		rightBelowArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverMiddleRight.png"]];
		[self addSubview:rightBelowArrow];
	}
	return rightBelowArrow;
}

- (UIImageView *)bottomLeft {
	if (bottomLeft == nil) {
		bottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverBottomLeft.png"]];
		[self addSubview:bottomLeft];
	}
	return bottomLeft;
}

- (UIImageView *)bottomLeftOfArrow {
	if (bottomLeftOfArrow == nil) {
		bottomLeftOfArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverBottomMiddle.png"]];
		[self addSubview:bottomLeftOfArrow];
	}
	return bottomLeftOfArrow;
}

- (UIImageView *)bottomRightOfArrow {
	if (bottomRightOfArrow == nil) {
		bottomRightOfArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverBottomMiddle.png"]];
		[self addSubview:bottomRightOfArrow];
	}
	return bottomRightOfArrow;
}

- (UIImageView *)bottomRight {
	if (bottomRight == nil) {
		bottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CalloutPopoverBottomRight.png"]];
		[self addSubview:bottomRight];
	}
	return bottomRight;
}


@end
