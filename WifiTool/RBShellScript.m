//
//  RBShellScript.m
//  WifiTool
//
//  Created by Rachel Brindle on 9/16/14.
//  Copyright (c) 2014 Rachel Brindle. All rights reserved.
//

#import "RBShellScript.h"

@implementation RBShellScript

+ (NSArray *)ls:(NSString *)directory
{
    if ([self isDirectory:directory]) {
        NSError *err = nil;
        NSArray *res = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&err];
        if (err != nil) {
            NSLog(@"Error listing %@: %@", directory, err);
        }
        return res;
    }
    return @[];
}

+ (NSString *)cat:(NSString *)file
{
    if ([self exists:file] && ![self isDirectory:file]) {
        NSError *err = nil;
        NSString *ret = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err];
        if (err != nil) {
            NSLog(@"Error getting contents of %@: %@", file, err);
        }
        return ret;
    }
    return @"";
}

+ (NSData *)data:(NSString *)file
{
    if ([self exists:file] && ![self isDirectory:file]) {
        NSError *err = nil;
        NSData *ret = [NSData dataWithContentsOfFile:file options:0 error:&err];
        if (err != nil) {
            NSLog(@"Error getting contents of %@: %@", file, err);
        }
        return ret;
    }
    return nil;
}

+ (NSString *)hexDump:(NSData *)data
{
    // outputs like hexdump -C
    NSUInteger len = [data length];
    NSUInteger lineLength = len / 16;
    const unsigned char * bytes = (const unsigned char *)data.bytes;
    NSMutableString *ret = [[NSMutableString alloc] init];
    for (int line = 0; line < lineLength; line++) {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%08x  ", line * 16];
        NSMutableString *ascii = [[NSMutableString alloc] init];
        for (int i = 0; i < 16; i++) {
            NSUInteger pos = (16 * line) + i;
            if (pos >= len) {
                break; // I should pad, but I won't.
            }
            
            unsigned char c = bytes[16 * line + i];
            if (c >= 0x20 && c < 0x7F) {
                [ascii appendFormat:@"%c", c];
            } else {
                [ascii appendString:@"."];
            }
            [str appendFormat:@"%02x ", c];
            if (i % 8 == 7) {
                [str appendString:@" "];
            }
        }
        [str appendFormat:@"|%@|\n", ascii];
        [ret appendString:str];
    }
    return [NSString stringWithString:ret];
}

+ (BOOL)exists:(NSString *)file
{
    return [[NSFileManager defaultManager] fileExistsAtPath:file];
}

+ (BOOL)isDirectory:(NSString *)file
{
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir];
    return isDir;
}

@end
