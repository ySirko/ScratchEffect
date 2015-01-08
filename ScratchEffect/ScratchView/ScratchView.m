//
//  ScratchView.m
//  ScratchEffect
//
//  Created by sirko on 12/18/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "ScratchView.h"

@implementation ScratchView

#pragma mark - Object Lifecycle

- (void)awakeFromNib
{
  CGColorSpaceRef colorSpace;
  CFMutableDataRef pixels;
  
  self.opaque = NO;
  self.scratchable = self.scratchableImage.CGImage;
  self.width = CGImageGetWidth(self.scratchable);
  self.height = CGImageGetHeight(self.scratchable);
  
  colorSpace = CGColorSpaceCreateDeviceGray();
  pixels = CFDataCreateMutable(NULL, self.width * self.height);
  self.provider = CGDataProviderCreateWithCFData(pixels);
  self.clearPixels = CGBitmapContextCreate(CFDataGetMutableBytePtr(pixels), self.width, self.height, 8, self.width, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
  
  CGContextSetFillColorWithColor(self.clearPixels, [UIColor blackColor].CGColor);
  CGContextFillRect(self.clearPixels, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height));

  CGContextSetStrokeColorWithColor(self.clearPixels, /*[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]].CGColor);*/[UIColor whiteColor].CGColor);
  CGContextSetLineWidth(self.clearPixels, 35.0);
  CGContextSetLineCap(self.clearPixels, kCGLineCapRound);
  
  CGImageRef mask = CGImageMaskCreate(self.width, self.height,8 /*CGImageGetBitsPerComponent(self.scratchable)*/,8 /*CGImageGetBitsPerPixel(self.scratchable)*/, self.width, self.provider, nil, NO);
  self.scratched = CGImageCreateWithMask(self.scratchable, mask);
  
  CGImageRelease(mask);
  CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect
{
  CGContextDrawImage(UIGraphicsGetCurrentContext(), [self bounds], self.scratched);
}

#pragma mark - Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [[event touchesForView:self] anyObject];
  self.isFirstTouch = YES;
  self.currentLocation = [touch locationInView:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [[event touchesForView:self] anyObject];
  
  if (self.isFirstTouch) {
    self.isFirstTouch = NO;
    self.previousLocation = [touch previousLocationInView:self];
  }else {
    self.currentLocation = [touch locationInView:self];
    self.previousLocation = [touch previousLocationInView:self];
  }
  
  [self writeLineFromPoint:self.previousLocation toPoint:self.currentLocation];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [[event touchesForView:self] anyObject];
  
  if (self.isFirstTouch) {
    self.isFirstTouch = NO;
    self.previousLocation = [touch previousLocationInView:self];
    [self writeLineFromPoint:self.previousLocation toPoint:self.currentLocation];
  }
}

#pragma mark - Private Methods

- (void)writeLineFromPoint:(CGPoint)currentPoint toPoint:(CGPoint)nextPoint
{
  CGContextMoveToPoint(self.clearPixels, currentPoint.x, currentPoint.y);
  CGContextAddLineToPoint(self.clearPixels, nextPoint.x, nextPoint.y);
  CGContextStrokePath(self.clearPixels);
  [self setNeedsDisplay];
}

@end
