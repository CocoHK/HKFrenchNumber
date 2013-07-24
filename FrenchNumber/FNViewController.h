//
//  ViewController.h
//  FrenchNumber
//
//  Created by Coco on 07/03/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FNViewController : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *normalBtn;
    IBOutlet UIButton *chequeBtn;
    IBOutlet UIButton *teleBtn;

    IBOutlet UITextView *showText;
    IBOutlet UITextField *typeText;
    
    BOOL buttonNumber;


}
-(IBAction)clickNormalBtn:(id)sender;
-(IBAction)clickChequeBtn:(id)sender;
-(IBAction)clickTeleBtn:(id)sender;


@property (nonatomic, retain) NSCharacterSet *positiveInt;
@property (nonatomic, retain) NSCharacterSet *point;
@property (nonatomic, retain) NSString *typeString;

@end
