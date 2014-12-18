//
//  ScratchView.h
//  ScratchEffect
//
//  Created by sirko on 12/18/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface ScratchView : UIView

@property (assign, nonatomic) CGPoint currentLocation;
@property (assign, nonatomic) CGPoint previousLocation;

@property (assign, nonatomic) BOOL isFirstTouch;

@property (assign, nonatomic) CGImageRef scratchable;
@property (assign, nonatomic) CGImageRef scratched;
@property (assign, nonatomic) CGContextRef clearPixels;
@property (assign, nonatomic) CGDataProviderRef provider;

@property (strong, nonatomic) IBInspectable UIImage *scratchableImage;

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@end
