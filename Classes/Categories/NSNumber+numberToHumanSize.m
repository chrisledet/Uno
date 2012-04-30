//
//  NSNumber+numberToHumanSize.m
//  UbuntuOne
//
//  Created by Chris Ledet on 4/30/12.
//  Copyright (c) 2012 Chris Ledet. All rights reserved.
//


#define KILOBYTE  1024
#define MEGABYTE  1024*1024
#define GIGABYTE  1024*1024*1024

#import "NSNumber+numberToHumanSize.h"

@implementation NSNumber (numberToHumanSize)

- (double) toGigabytes
{
    return ([self doubleValue] / 1024) / 1024 / 1024.0;
}

- (double) toMegabytes
{
    return ([self doubleValue] / 1024) / 1024.0;
}

- (double) toKilobytes
{
    return [self doubleValue] / 1024.0;
}

- (NSString*) numberToHumanSize
{
    NSString* humanSize;
    double value = [self doubleValue];
    
    if (value >= GIGABYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fGB", [self toGigabytes]];
    } else if (value >= MEGABYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fMB", [self toMegabytes]];
    } else if (value >= KILOBYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fKB", [self toKilobytes]];
    } else {
        humanSize = [NSString stringWithFormat:@"%.2f Bytes", value];
    }
    
    return humanSize;
}

@end
