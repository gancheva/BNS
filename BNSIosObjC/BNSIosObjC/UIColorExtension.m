//
//  UIColorExtension.m
//  TestObjCPebbleConnectivity
//
//  Created by Kristina Gancheva on 12/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
//  This extension was written by yeahdongcn and can be retrieved from https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift
//  It was based on Erica Sadun's NSColor extention https://github.com/erica/uicolor-utilities/blob/master/NSColor/NSColorUtils.m

#import "UIColorExtension.h"

@implementation UIColor (Extensions)

+ (UIColor *)colorFromHex:(NSString *) rgba {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 1.0;
    
    if ([rgba hasPrefix: @"#"]) {
        rgba = [rgba substringFromIndex:1];
        NSScanner *scanner = [NSScanner scannerWithString:rgba];
        unsigned hex = 0;
        if ([scanner scanHexInt: &hex]) {
            if ([rgba length] == 6) {
                red   = ((hex & 0xFF0000) >> 16) / 255.0;
                green = ((hex & 0x00FF00) >> 8)  / 255.0;
                blue  = (hex & 0x0000FF) / 255.0;
            } else if ([rgba length] == 8) {
                red   = ((hex & 0xFF000000) >> 24) / 255.0;
                green = ((hex & 0x00FF0000) >> 16) / 255.0;
                blue  = ((hex & 0x0000FF00) >> 8)  / 255.0;
                alpha = (hex & 0x000000FF)         / 255.0;
            } else {
                NSLog(@"%@", @"Invalid rgb string, length should be 7 or 9");
            }
        } else {
            NSLog(@"%@", @"Scan hex error.");
        }
    } else {
        NSLog(@"%@", @"Invalid rgb string, missing '#' as prefix");
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

