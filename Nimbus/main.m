//
//  main.c
//  Nimbus
//
//  Created by Sagar Pandya on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <OSXFUSE/OSXFUSE.h>
#import <Cocoa/Cocoa.h>
#import "APITest.h"

int main (int argc, const char * argv[])
{
    APITest* test = [[APITest alloc] init];
    
    [test doTest];
    
    while(1);
    
    [test dealloc];
    return 0;
}