//
//  GameKitMessageViewController.h
//  GameKitMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface GameKitMessageViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate> {
    
    UITextField *_sendTextField;
    UIButton *_sendButton;
    UIButton *_connectButton;
    
    GKSession *_session;
    NSString *_peerID;
}

- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)connectButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UITextField *sendTextField;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;

@end
