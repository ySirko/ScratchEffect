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
  
  CGContextSetFillColorWithColor(self.clearPixels, /*[UIColor colorWithPatternImage:[UIImage imageNamed:@"whiteBlob.jpg"]].CGColor);*/[UIColor blackColor].CGColor);
  CGContextFillRect(self.clearPixels, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height));

  CGContextSetStrokeColorWithColor(self.clearPixels, /*[UIColor colorWithPatternImage:[UIImage imageNamed:@"whiteBlob.jpg"]].CGColor);*/[UIColor whiteColor].CGColor);
  CGContextSetLineWidth(self.clearPixels, 25.f);
  CGContextSetLineCap(self.clearPixels, kCGLineCapRound);
  
  CGImageRef mask = CGImageMaskCreate(self.width, self.height, 8, 8,/*CGImageGetBitsPerComponent(self.scratchable),CGImageGetBitsPerPixel(self.scratchable),*/ self.width, self.provider, nil, NO);
  
  self.scratched = CGImageCreateWithMask(self.scratchable, mask);
  
  CGImageRelease(mask);
  CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect
{
  CGContextDrawImage(UIGraphicsGetCurrentContext(), [self bounds], self.scratched);
  UIImage *texture = [UIImage imageNamed:@"whiteBlob.jpg"];
  
  CGPoint point = CGPointMake(self.currentLocation.x - CGImageGetWidth(texture.CGImage)/2, self.currentLocation.y - CGImageGetHeight(texture.CGImage)/2);
  NSLog(@"Point = %@", NSStringFromCGPoint(point));
  
  [texture drawAtPoint:point blendMode:kCGBlendModeNormal alpha:1.f];
  
  /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSInteger count = 0;
    
    for (CGFloat i = 0.0; i < CGImageGetWidth(self.scratched); i++) {
      for (CGFloat j = 0.0; j < CGImageGetHeight(self.scratched); j++) {
        NSLog(@"i=%f j=%f", i, j);
        CGPoint currentPoint = CGPointMake(i, j);
        if (CGColorEqualToColor([self colorOfPoint:currentPoint].CGColor, [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f].CGColor)) {
          count++;
        };
      }
    }
    NSLog(@"Count = %d", count);
  });*/
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
  //CGContextAddQuadCurveToPoint(self.clearPixels, currentPoint.x, currentPoint.y, nextPoint.x, nextPoint.y);
  CGContextAddLineToPoint(self.clearPixels, nextPoint.x, nextPoint.y);
  CGContextStrokePath(self.clearPixels);
  [self setNeedsDisplay];
  
  //NSLog(@"Line = %f", sqrt(pow(nextPoint.x - currentPoint.x, 2) + pow(nextPoint.y - currentPoint.y, 2)));
  
}

- (UIColor*)colorOfPoint:(CGPoint)point
{
  UIColor *color;
  size_t width = 1;
  size_t height = 1;
  size_t bitsPerComponent = 8;
  size_t bytesPerRow = 4;
  unsigned char pixel[4] = {0};
  CGContextRef context;
  
  context = CGBitmapContextCreate(pixel, width, height, bitsPerComponent, bytesPerRow, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
  CGContextTranslateCTM(context, -point.x, -point.y);
  
  [self.layer renderInContext:context];
  CGContextRelease(context);
  
  color = [UIColor colorWithRed:pixel[0]/255.f green:pixel[1]/255.f blue:pixel[2]/255.f alpha:pixel[3]/255.f];
  
  return color;
}

@end
