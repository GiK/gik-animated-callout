//
//  GIKAnnotationView.m
//  AnimatedCallout
//
//  Created by Gordon on 2/15/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import "GIKAnnotationView.h"


@implementation GIKAnnotationView
@synthesize selectionEnabled;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (!(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		return nil;
	}
	
	[self setSelectionEnabled:YES];
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (self.selectionEnabled) {
		[super setSelected:selected animated:animated];
		
		// If you have implemented your own custom pin image, set it here, otherwise selection may reset the image.
		// self.image = [UIImage imageNamed:@"mypinimage.png"];
	}
}

- (BOOL)isSelectionEnabled {
	return selectionEnabled;
}

@end
