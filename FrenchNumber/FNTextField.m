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

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    self.layer.cornerRadius = 2.0;
    self.layer.borderColor = [[UIColor colorWithWhite:0.75 alpha:1] CGColor];
    self.layer.borderWidth = 1;
}

//- (void)drawRect:(CGRect)rect {
//    UIBezierPath *innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -1, -1)
//                                                               cornerRadius:self.layer.cornerRadius];
//    
//    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 2), 3, [UIColor blackColor].CGColor);
//    
//    [[UIColor blackColor] setStroke];
//    [innerShadowPath stroke];
//}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
