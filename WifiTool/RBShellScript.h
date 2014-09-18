//
//  RBShellScript.h
//  WifiTool
//
//  Created by Rachel Brindle on 9/16/14.
//  Copyright (c) 2014 Rachel Brindle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBShellScript : NSObject

+ (NSArray *)ls:(NSString *)directory;
+ (NSString *)cat:(NSString *)file;

+ (NSData *)data:(NSString *)file;
+ (NSString *)hexDump:(NSData *)data;

+ (BOOL)exists:(NSString *)file;
+ (BOOL)isDirectory:(NSString *)file;

@end
