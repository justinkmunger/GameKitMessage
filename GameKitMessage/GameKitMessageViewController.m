//
//  GameKitMessageViewController.m
//  GameKitMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "GameKitMessageViewController.h"

@interface GameKitMessageViewController ()

@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *peerID;
@end

@implementation GameKitMessageViewController

@synthesize sendTextField = _sendTextField;
@synthesize sendButton = _sendButton; 
@synthesize connectButton = _connectButton;

@synthesize session = _session;
@synthesize peerID = _peerID;

- (void)dealloc
{
    [_sendTextField release];
    [_sendButton release];
    [_connectButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sendButton.hidden = YES;
    self.sendTextField.enabled = NO;
    self.connectButton.hidden = NO;
}


- (void)viewDidUnload
{
    [self setSendTextField:nil];
    [self setSendButton:nil];
    [self setConnectButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendButtonPressed:(id)sender {    
    if (self.session != nil) {
        NSDictionary *packetDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIDevice currentDevice].name, @"sender", self.sendTextField.text, @"message", nil];
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:packetDictionary];
        NSMutableData *packetData = [[NSMutableData alloc] init];
        
        int packetLength = archivedData.length;
        
        [packetData appendBytes:&packetLength length:sizeof(int)];
        [packetData appendData:archivedData];        
        
        [self.session sendData:packetData 
                       toPeers:[NSArray arrayWithObjects:self.peerID, nil] 
                  withDataMode:GKSendDataReliable 
                         error:nil];
        
        [packetData release];
        
        self.sendTextField.text = @"";

    }
}

- (IBAction)connectButtonPressed:(id)sender {
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    [picker show];
}

#pragma - 
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate methods
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type{	
    
	GKSession *theSession = [[GKSession alloc] initWithSessionID:@"com.berksoft.gamekitmessage" displayName:nil sessionMode:GKSessionModePeer]; 
    return [theSession autorelease]; 
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)thePeerID toSession:(GKSession *)theSession {
	    
	self.session = theSession;
	self.session.delegate = self; 
    self.peerID = thePeerID; 

	[self.session setDataReceiveHandler:self withContext:NULL];
	
	[picker dismiss];
	picker.delegate = nil;
	[picker release];
}

#pragma mark -
#pragma mark GKSessionDelegate methods
- (void)session:(GKSession *)session 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state {
    NSLog(@"didChangeState was called from peerID: %@.", peerID);    
	
    switch (state) {			
        case GKPeerStateConnected:
            NSLog(@"Peer %@ Connected", self.peerID);
            self.sendButton.hidden = NO;
            self.connectButton.hidden = YES;
            self.sendTextField.enabled = YES;
            break;
			
        case GKPeerStateDisconnected:
            NSLog(@"Peer %@ Disconnected", self.peerID);
            self.sendButton.hidden = YES;
            self.connectButton.hidden = NO;
            self.sendTextField.enabled = NO;
            break;  
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    int length;
    [data getBytes:&length length:sizeof(int)];
    
    if (length == data.length - sizeof(int)) {
        uint8_t packetData[length];
        
        [data getBytes:packetData range:NSMakeRange(sizeof(int), length)];
        NSDictionary *packet = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:packetData length:length]];

        NSString *name = [packet objectForKey:@"sender"];
        NSString *messageText = [packet objectForKey:@"message"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:name 
                                                        message:messageText 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    }
}

@end
