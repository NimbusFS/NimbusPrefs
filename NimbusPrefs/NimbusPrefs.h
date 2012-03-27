//
//  NimbusPrefs.h
//  NimbusPrefs
//
//  Created by Sagar Pandya on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface NimbusPrefs : NSPreferencePane
{
    IBOutlet NSWindow *window;
}

@property (assign) IBOutlet NSButton *mountButton;
@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSSecureTextField *passwordField;
@property (assign) IBOutlet NSTextField *mountPathField;
@property (assign) IBOutlet NSTextField *loginFailedLabel;
@property (assign) IBOutlet NSProgressIndicator *loginProgressIndicator;
@property (assign) IBOutlet NSTextField *descriptionLabel;

NSArray *getCloudAppInfoFromKeychain();
- (void)mainViewDidLoad;
- (void)mountResult:(NSNotification *)notification;

- (IBAction)mount:(id)sender;

@end
