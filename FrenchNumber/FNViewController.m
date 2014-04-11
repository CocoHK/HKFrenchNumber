//
//  ViewController.m
//  FrenchNumber
//
//  Created by Coco on 07/03/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import "FNViewController.h"

#import "MFUnderlinedTextView.h"
#import "FNTextField.h"
#import "FNTranslateNumberToFrench.h"

@interface FNViewController () <UITextFieldDelegate,ADBannerViewDelegate> {
//    CGRect originalBounds;
    CGRect originalFrame;

}

@property (nonatomic, retain) UIButton *dotButton;
@property (nonatomic, retain) FNTranslateNumberToFrench *translator;

- (IBAction)changeMode:(id)sender;

@end

@implementation FNViewController

#pragma mark keyboard

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(KeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroud.jpg"]];
    typeText.frame = CGRectMake(20, 20, 280, 35);
}


- (void)KeyboardWillShowNotification:(NSNotification *)notification {

//    CGRect finalRect;
//    originalFrame = self.view.frame;
    NSLog(@"originalFrame is %@",NSStringFromCGRect(originalFrame));

    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"keyboard info is %@",[notification userInfo]);
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]getValue:&animationCurve];
    NSLog(@"CurveUserInfoKey is %d",animationCurve);

    NSLog(@"kbSize is %@",NSStringFromCGSize(kbSize));

    [UIView animateWithDuration:0.25
                          delay:0
                        options:7
                     animations:^{
                         [self changeFrame:kbSize];
                     } completion:^(BOOL finished) {

                     }
    ];
    
    adView.hidden = YES;
    normalBtn.hidden = YES;
    chequeBtn.hidden = YES;
    teleBtn.hidden = YES;
}

- (void)changeFrame: (CGSize) keyboradSize {
    CGSize kbSize = keyboradSize;
    originalFrame = self.view.frame;
    CGRect finalRect;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            finalRect = CGRectMake(originalFrame.origin.x,originalFrame.origin.y,originalFrame.size.width,originalFrame.size.height - kbSize.height+40);
            break;
        case UIInterfaceOrientationLandscapeRight:
            finalRect = CGRectMake(kbSize.width,originalFrame.origin.y,originalFrame.size.width - kbSize.width ,originalFrame.size.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            finalRect = CGRectMake(originalFrame.origin.x,originalFrame.origin.y,originalFrame.size.width - kbSize.width,originalFrame.size.height);
            break;
        default:
            break;
    }
    self.view.frame = finalRect;
}
- (void)keyboardWillHideNotification:(NSNotification *)notification {
    self.view.frame =  originalFrame;
    adView.hidden = NO;
    normalBtn.hidden = NO;
    chequeBtn.hidden = NO;
    teleBtn.hidden = NO;

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)dismissKeyboard {
    [typeText resignFirstResponder];
}



#pragma mark 

- (void)viewDidLoad {
    adView.delegate = self;

//    typeText.borderStyle = UITextBorderStyleNone;
    typeText.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    typeText.clipsToBounds = YES;
    
    typeText.layer.cornerRadius = 6.0;
    typeText.layer.borderColor = [[UIColor clearColor] CGColor];
    typeText.layer.borderWidth = 1;
//    typeText.layer.shadowColor = [[UIColor blackColor] CGColor];
//    typeText.layer.shadowOpacity = 1.0;
//    typeText.layer.shadowRadius = 3.0;
//    typeText.layer.shadowOffset = CGSizeMake(0,3);

    normalBtn.layer.cornerRadius = 5.0;
    chequeBtn.layer.cornerRadius = 5.0;
    teleBtn.layer.cornerRadius = 5.0;
    [showText setUnderlineColor:[UIColor colorWithWhite:0 alpha:0.1]];

    self.translator = [[FNTranslateNumberToFrench new] autorelease];
    
//    self.positiveInt = [NSCharacterSet characterSetWithCharactersInString:@"123456789"];
//    self.point =[NSCharacterSet characterSetWithCharactersInString:@"."];
    
    
    [self setTranslationMode:0];
//    [chequeBtn addTarget:self action:@selector(setTranslationMode:)forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap release];
    [super viewDidLoad];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    NSLog(@"%@",NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]));
    NSLog(@"frame%@",NSStringFromCGRect(self.view.frame));

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark changeTranslateMode

- (IBAction)changeMode:(id)sender {
    [self setTranslationMode:((UIButton *)sender).tag];
    
    NSLog(@"translationMode is %d",translateMode);
}

- (void)setTranslationMode:(int)mode {
    translateMode = mode;
    [self updateTranslateMode:mode];
    
}

- (void)updateTranslateMode:(int)currentMode {
    typeText.attributedText = nil;
    typeText.text = self.typeString;
    typeText.textColor = [UIColor blackColor];
    switch (translateMode) {
        case 0:{
            [typeText setKeyboardType:UIKeyboardTypeDecimalPad];
            [self translateNumber];
            NSLog(@"typestring is %@",self.typeString);
        }
            break;
        case 1:
        {
            [typeText setKeyboardType:UIKeyboardTypeDecimalPad];
            [self translateNumber];
            
            NSUInteger pointLocation = [self.typeString rangeOfCharacterFromSet:self.point].location;
            if (pointLocation != NSNotFound &&
                pointLocation < [self.typeString length] - 1) {//存在小数点并且后存在数字大于2
                NSString *decimalString = [self.typeString substringFromIndex:pointLocation+1];//小数点后的所有数字
                NSLog(@"decimalString is %@ %d",decimalString,[decimalString length]);
                NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:self.typeString] autorelease];
                if (([self.typeString length] - pointLocation - 1) > 2) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(pointLocation+3, [self.typeString length] - pointLocation - 3)];//小数点后第三位开始变成灰色
                }
                NSLog(@"typeString is%d point is %d",[self.typeString length],pointLocation);
                
                typeText.attributedText = attributedString;
            }
        }
            break;
        case 2:
        {
            [typeText setKeyboardType:UIKeyboardTypeNumberPad];
            NSLog(@"typestring is %@",self.typeString);
            [self translateTele];
            
            
            NSUInteger pointLocation = [self.typeString rangeOfCharacterFromSet:self.point].location;
//            NSNumber *noPointNumber;
//            if (pointLocation !=NSNotFound) {
//                NSString * noPointString = [self.typeString stringByReplacingOccurrencesOfString:@"." withString:@""];
//                noPointNumber = [NSNumber numberWithInt:[noPointString intValue]];
//            }
//            else {
//                noPointNumber = [NSNumber numberWithInt:[self.typeString intValue]];
//            }
//            NSNumberFormatter *numberFormatter = [[NSNumberFormatter new]autorelease];
//            [numberFormatter setUsesGroupingSeparator:YES];
//            [numberFormatter setGroupingSeparator:@" "];
//            [numberFormatter setGroupingSize:2];

//            self.typeString = [numberFormatter stringFromNumber:noPointNumber];
            
            
            NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:self.typeString] autorelease];

            if ([self.typeString length] <= 10 && pointLocation != NSNotFound) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(pointLocation,1)];
            }
            else if ([self.typeString length] > 10) {
                if ((pointLocation != NSNotFound && pointLocation > 9)||(pointLocation == NSNotFound)) {
                    if (pointLocation != NSNotFound) {
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(pointLocation,1)];

                    }
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(10,[self.typeString length]-10)];
                }
                else {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(pointLocation,1)];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(11,[self.typeString length]-11)];
                    
                }
            }
            typeText.attributedText = attributedString;

            
        }
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    showText.text = @"";

    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *temString;
    BOOL returnValue = YES;

    if (translateMode == 0 || translateMode == 1) {
        // add numbers
        if (range.length == 0) {
            temString = [textField.text stringByAppendingString:string];
            NSString *regex = @"^\\d*[\\.]?\\d*$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL isMatch = [predicate evaluateWithObject:temString];

            if (isMatch) {
                //judge when the first character is 0

                    if ([temString characterAtIndex:0] == '0'&&
                        [temString length] >= 2 &&
                        ([temString characterAtIndex:1] != '.' &&
                         [temString characterAtIndex:1] != ','))

                    isMatch = NO;
            }
            if (isMatch) {

                if ([temString rangeOfCharacterFromSet:self.point].location == NSNotFound){
                    if ([temString length] > 23)
                isMatch = NO;
                }
                else{
                    int location = [temString rangeOfCharacterFromSet:self.point].location;

                    if (translateMode == 0) {

                        if ([[temString substringToIndex:location] length] > 23 ||
                            [[temString substringFromIndex:location+1] length] > 21)
                        isMatch = NO;
                    }
                    else if (translateMode == 1){

                        if ([[temString substringToIndex:location] length] > 23 ||
                            [[temString substringFromIndex:location+1] length] > 2)
                            isMatch = NO;
                    }
                }
                
            }
            
            
            if (isMatch) {
//                [self translateNumber];
                returnValue = YES;
            }
            else{
//                return NO;
                returnValue = NO;
            }
        }
        
        else{
            //delete numbers
            
            if ([textField.text length] > range.length) {

                temString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
                NSLog(@"textfield is %d range is %d string is %@  typestring is %@",[textField.text length],range.length,string,temString);
//                self.typeString = temString;
//                [self translateNumber];
                returnValue = YES;
            }
            else{
                showText.text =@"";
            }}
        
    }
    
    
    //translate telephone number
    else if (translateMode == 2){

        //add numbers
        if (range.length == 0) {
            
            temString = [textField.text stringByAppendingString:string];

            NSString *regex = @"^\\d{1,10}$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL isMatch = [predicate evaluateWithObject:temString];
            
            if (isMatch) {
//                self.typeString = temString;
//                [self translateTele];
                
                returnValue = YES;
            }
            else{
//                NSLog(@"typeString is %@",self.typeString);

                returnValue = NO;

            }
            
        }
        else{
            //delete numbers
            if ([textField.text length] > range.length) {
                temString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
//                self.typeString = temString;
//                [self translateTele];
                returnValue = YES;
                
            }
            else{
                showText.text =@"";
            }
        
//        NSLog(@"typeString is %@",self.typeString);
        }
    }
    
//    return YES;
    if (returnValue) {
        self.typeString = temString;
        if (translateMode == 0 || translateMode ==1) {

            [self translateNumber];
            }
        else if (translateMode == 2){

            [self translateTele];

        }
        
    
    }
    return returnValue;
}


#pragma mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%@",[error description]);
//    adView.hidden = YES;
}

@end
