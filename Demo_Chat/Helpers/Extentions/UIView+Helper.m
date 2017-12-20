//
//  UIView+Helper.m
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/6/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (void)addBorderToAllSubViews {
    for (UIView * view in [self subviews]) {
        view.layer.borderColor = [UIColor yellowColor].CGColor;
        view.layer.borderWidth = 1;
        
        [view addBorderToAllSubViews];
        
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.borderWidth = 1;
    }
}

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color {
    // MFLAssert(source && color, @"Source and color should not be nil");
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
