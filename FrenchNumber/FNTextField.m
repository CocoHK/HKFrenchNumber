//
//  FNTextField.m
//  FrenchNumber
//
//  Created by Coco on 18/08/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FNTextField.h"

@implementation FNTextField

- (void)drawRect:(CGRect)rect {
    UIBezierPath *innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -1, -1)
                                                               cornerRadius:self.layer.cornerRadius];
    
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 2), 3, [UIColor blackColor].CGColor);
    
    [[UIColor blackColor] setStroke];
    [innerShadowPath stroke];
}   

@end
