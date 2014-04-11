//
//  FNTranslateNumberToFrench.h
//  FrenchNumber
//
//  Created by Coco on 07/09/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNTranslateNumberToFrench : NSObject
- (NSString *)translateTele:(NSString *)inputNumber translateMode:(int)mode;
- (NSString *)translateNumber:(NSString *)inputNumber translateMode:(int)mode;

@property(nonatomic, retain) NSString *importValue;
@property (nonatomic, retain) NSString *decimalSeparator;
@property (nonatomic, retain) NSCharacterSet *positiveInt;



@end
