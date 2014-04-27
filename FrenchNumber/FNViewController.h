//
//  ViewController.h
//  FrenchNumber
//
//  Created by Coco on 07/03/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>

@class MFUnderlinedTextView;
@class FNTextField;

@interface FNViewController : UIViewController  {
    IBOutlet UIButton *normalBtn;
    IBOutlet UIButton *chequeBtn;
    IBOutlet UIButton *teleBtn;

    IBOutlet MFUnderlinedTextView *showText;
    IBOutlet FNTextField *typeText;
    IBOutlet ADBannerView *adView;
    
    int translateModel;
}

@property (nonatomic, retain) NSCharacterSet *positiveInt;
@property (nonatomic, retain) NSCharacterSet *point;
@property (nonatomic, retain) NSString *typeString;

- (IBAction)changeMode:(id)sender;

@end
