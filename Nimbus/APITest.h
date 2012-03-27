//
//  APITest.h
//  NimbusPrefs
//
//  Created by Sagar Pandya on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cloud.h"

@interface APITest : NSObject <NSApplicationDelegate>
{
    CLAPIEngine* cloudEngine;
}

@property (retain, nonatomic) CLAPIEngine* cloudEngine;

-(APITest*) init;
-(void) doTest;
-(void) getThings:(id)whatever;
@end