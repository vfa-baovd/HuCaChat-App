//
//  UIView+Helper.h
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/6/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Debug)

- (void)addBorderToAllSubViews;

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color;

@end
