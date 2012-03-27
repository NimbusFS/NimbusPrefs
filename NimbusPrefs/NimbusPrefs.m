//
//  NimbusPrefs.m
//  NimbusPrefs
//
//  Created by Sagar Pandya on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NimbusPrefs.h"
#import "NSAttributedString+Hyperlink.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

@implementation NimbusPrefs

@synthesize mountButton = _mountButton;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize mountPathField = _mountPathField;
@synthesize loginFailedLabel = _loginFailedLabel;
@synthesize loginProgressIndicator = _loginProgressIndicator;
@synthesize descriptionLabel = _descriptionLabel;

NSArray *getCloudAppInfoFromKeychain()
{
    UInt32 passwordLength = 0;
    char *password = nil;
    
    SecKeychainItemRef item = nil;
    OSStatus ret = SecKeychainFindGenericPassword(NULL, 5, "Cloud", 0, NULL, &passwordLength, (void**)&password, &item);
    
    UInt32 attributeTags[1];
    *attributeTags = kSecAccountItemAttr;
    
    UInt32 formatConstants[1];
    *formatConstants = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
    
    struct SecKeychainAttributeInfo
    {
        UInt32 count;
        UInt32 *tag;
        UInt32 *format;
    } attributeInfo;
    
    attributeInfo.count = 1;
    attributeInfo.tag = attributeTags;
    attributeInfo.format = formatConstants;
    
    SecKeychainAttributeList *attributeList = nil;
    OSStatus attributeRet = SecKeychainItemCopyAttributesAndData(item, &attributeInfo, NULL, &attributeList, 0, NULL);
    
    if (attributeRet != noErr || !item)
    {
        NSLog(@"Error - %s", GetMacOSStatusErrorString(ret));
        return nil;
    }
    
    SecKeychainAttribute accountNameAttribute = attributeList->attr[0];
    NSString* accountName = [[[NSString alloc] initWithData:[NSData dataWithBytes:accountNameAttribute.data length:accountNameAttribute.length] encoding:NSUTF8StringEncoding] autorelease];
    
    NSString *passwordString = [[[NSString alloc] initWithData:[NSData dataWithBytes:password length:passwordLength] encoding:NSUTF8StringEncoding] autorelease];

    SecKeychainItemFreeContent(NULL, password);
    
    return [[NSArray alloc] initWithObjects:accountName, passwordString, nil];
}

- (void)mainViewDidLoad
{
    NSArray* loginInfo = getCloudAppInfoFromKeychain();
    NSString *username;
    NSString *password;

    if (loginInfo == nil)
    {
        [_usernameField bind:@"value"
                    toObject:[NSUserDefaultsController sharedUserDefaultsController]
                 withKeyPath:@"values.NimbusUserName"
                     options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:@"NSContinuouslyUpdatesValue"]];
    }
    else
    {
        username = [loginInfo objectAtIndex:0];
        password = [loginInfo objectAtIndex:1];
        [_usernameField setStringValue:username];
        [_passwordField setStringValue:password];
    }
    
    [_mountPathField bind:@"value"
                 toObject:[NSUserDefaultsController sharedUserDefaultsController]
              withKeyPath:@"values.NimbusMountPath"
                  options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                      forKey:@"NSContinuouslyUpdatesValue"]];    
    
    [_descriptionLabel setAllowsEditingTextAttributes: YES];
    [_descriptionLabel setSelectable: YES];
    
    NSURL* url = [NSURL URLWithString:@"http://getcloudapp.com"];

    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:@"Get a CloudApp account at "];
    [string appendAttributedString:[NSAttributedString hyperlinkFromString:@"www.getcloudapp.com" withURL:url]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@". Then sign in below."]];

    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSFont fontWithName:@"Lucida Grande" size:13], NSFontAttributeName,
                                nil];
    NSRange range = NSMakeRange(0, [string length]);
    [string addAttributes:attributes range:range];

    [_descriptionLabel setAttributedStringValue:string];
    
    [_loginFailedLabel setHidden:YES];
    [_loginProgressIndicator setHidden:YES];
    
    NSDistributedNotificationCenter* distributedCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedCenter addObserver: self
                          selector: @selector(mountResult:)
                              name: @"mountResult"
                            object: nil];
}

-(void) mount:(id)selector
{
    NSLog(@"Sending notification");
    
    NSString *observedObject = @"com.sagargp.Nimbus";
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];

    NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"username", [_usernameField stringValue],
                              @"password", [_passwordField stringValue],
                              @"mountPath", [_mountPathField stringValue], nil];
    
    [center postNotificationName: @"mountClickedInPrefPane"
                          object: observedObject
                        userInfo: userInfo /* no dictionary */
              deliverImmediately: YES];

    [_usernameField setEnabled:NO];
    [_passwordField setEnabled:NO];
    [_mountButton setEnabled:NO];
    [_loginProgressIndicator setHidden:NO];
}

-(void) mountResult:(NSNotification *)notification
{
    NSLog(@"Received notification");
    NSDictionary* userInfo = [notification userInfo];
    NSString* successful = [userInfo objectForKey:@"successful"];
    
    if ([successful isEqualToString:@"no"])
    {
        // failed
        [_usernameField setEnabled:YES];
        [_passwordField setEnabled:YES];
        [_mountButton setEnabled:YES];
        [_loginFailedLabel setHidden:NO];
        [_loginProgressIndicator setHidden:YES];
    }
    else if ([successful isEqualToString:@"yes"])
    {
        // succeeded
        [_usernameField setEnabled:NO];
        [_passwordField setEnabled:NO];
        [_mountButton setEnabled:YES];
        [_mountButton setTitle:@"Unmount"];
        [_loginFailedLabel setHidden:YES];
        [_loginProgressIndicator setHidden:YES];
    }
}

@end
