//
//  AnimatedCalloutAppDelegate.h
//  AnimatedCallout
//
//  Created by Gordon on 2/14/11.
//  Copyright 2011 GeeksInKilts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface AnimatedCalloutAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MapViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MapViewController *viewController;

@end

