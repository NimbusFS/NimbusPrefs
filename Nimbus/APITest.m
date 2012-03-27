//
//  APITest.m
//  NimbusPrefs
//
//  Created by Sagar Pandya on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APITest.h"

@interface APITest () <CLAPIEngineDelegate>
@end

@implementation APITest
@synthesize cloudEngine;

-(void) dealloc
{
    NSLog(@"Deallocating APITest");
}

-(APITest *) init
{
    self = [super init];
    if (!self)
        return nil;

    self.cloudEngine = [CLAPIEngine engineWithDelegate:self];
    cloudEngine.email = @"sagargp@gmail.com";
    cloudEngine.password = @"wetfeet";
    
    return self;
}

-(void) doTest
{
    [[NSRunLoop mainRunLoop] performSelector:@selector(getThings) target:self argument:nil order:1 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

-(void) getThings:(id)whatever
{
    NSLog(@"Getting account info");
    [cloudEngine getItemListStartingAtPage:1 itemsPerPage:5 userInfo:nil];
}

- (void)itemListRetrievalSucceeded:(NSArray *)items connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
	NSLog(@"[ITEM LIST]: %@, %@", connectionIdentifier, items);
}

- (void)requestDidFailWithError:(NSError *)error connectionIdentifier:(NSString *)connectionIdentifier userInfo:(id)userInfo {
	NSLog(@"[FAIL]: %@, %@", connectionIdentifier, error);
}

@end