//
//  GameKitMessageAppDelegate.h
//  GameKitMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameKitMessageViewController;

@interface GameKitMessageAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet GameKitMessageViewController *viewController;

@end
