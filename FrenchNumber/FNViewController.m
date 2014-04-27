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
#import "Transform.h"

@interface FNViewController () <UITextFieldDelegate,ADBannerViewDelegate> {
    CGRect originalFrame;
    
}

@property (nonatomic, retain) UIButton *dotButton;

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
    self.typeString = @"";
}


- (void)KeyboardWillShowNotification:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]getValue:&animationCurve];
    
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
    
    normalBtn.layer.cornerRadius = 5.0;
    chequeBtn.layer.cornerRadius = 5.0;
    teleBtn.layer.cornerRadius = 5.0;
    [showText setUnderlineColor:[UIColor colorWithWhite:0 alpha:0.1]];
    
    self.positiveInt = [NSCharacterSet characterSetWithCharactersInString:@"123456789"];
    self.point =[NSCharacterSet characterSetWithCharactersInString:@".,"];
    
    [self setTranslationMode:0];
    //    [chequeBtn addTarget:self action:@selector(setTranslationMode:)forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap release];
    [super viewDidLoad];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark changeTranslateMode

- (IBAction)changeMode:(id)sender {
    [self setTranslationMode:(int)((UIButton *)sender).tag];
}

- (void)setTranslationMode:(int)mode {
    translateModel = mode;
    [self updateKeyboard:mode];
    
}

- (void)updateKeyboard:(int)currentMode {
    typeText.attributedText = nil;
    typeText.text = self.typeString;
    switch (translateModel) {
        case 0:{
            [typeText setKeyboardType:UIKeyboardTypeDecimalPad];
//            [self translateNumber];修改1
            showText.text = [Transform translateNumberWithString:self.typeString model:currentMode];

        }
            break;
        case 1:
        {
            [typeText setKeyboardType:UIKeyboardTypeDecimalPad];
//            [self translateNumber];修改2
            showText.text = [Transform translateNumberWithString:self.typeString model:currentMode];
            
            NSUInteger pointLocation = [self.typeString rangeOfCharacterFromSet:self.point].location;
            
            NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:self.typeString] autorelease];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [self.typeString length])];
            
            if (pointLocation != NSNotFound &&
                [self.typeString length] - pointLocation - 1 > 2) {
                NSRange grayRange = NSMakeRange(pointLocation+3, [self.typeString length] - pointLocation - 3);
                [attributedString removeAttribute:NSForegroundColorAttributeName range:grayRange];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:grayRange];
            }
            typeText.attributedText = attributedString;
        }
            break;
        case 2:
        {
            [typeText setKeyboardType:UIKeyboardTypeNumberPad];
            
//            [self translateTele];修改3
            showText.text = [Transform translateNumberWithString:self.typeString model:translateModel];
            
            NSUInteger pointLocation = [self.typeString rangeOfCharacterFromSet:self.point].location;
            
            NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:self.typeString] autorelease];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [self.typeString length])];
            
            if (pointLocation != NSNotFound) {
                NSRange rangeAfterPoint = NSMakeRange(pointLocation,[self.typeString length]-pointLocation);
                [attributedString removeAttribute:NSForegroundColorAttributeName range:rangeAfterPoint];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:rangeAfterPoint];
            }
            if ([self.typeString length] > 10) {
                NSRange rangeAfterTen = NSMakeRange(10,[self.typeString length]-10);
                [attributedString removeAttribute:NSForegroundColorAttributeName range:rangeAfterTen];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:rangeAfterTen];
            }
            typeText.attributedText = attributedString;
        }
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    showText.text = @"";
    self.typeString = @"";
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *temString = @"";
    BOOL returnValue;
    if (translateModel == 0 || translateModel == 1) {
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
                    int location = (int)[temString rangeOfCharacterFromSet:self.point].location;
                    
                    if (translateModel == 0) {
                        if ([[temString substringToIndex:location] length] > 23 ||
                            [[temString substringFromIndex:location+1] length] > 21)
                            isMatch = NO;
                    }
                    else if (translateModel == 1){
                        if ([[temString substringToIndex:location] length] > 23 ||
                            [[temString substringFromIndex:location+1] length] > 2)
                            isMatch = NO;
                    }
                }
                
            }
            
            if (isMatch) {
                self.typeString = temString;
//                [self translateNumber];修改4
                showText.text = [Transform translateNumberWithString:self.typeString model:translateModel];
            }
            else{
                returnValue = NO;
            }
        }
        
        else{
            //delete numbers
            if ([textField.text length] > range.length) {
                temString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
                self.typeString = temString;
//                [self translateNumber];修改5
                showText.text = [Transform translateNumberWithString:self.typeString model:translateModel];
            }
            else{
                showText.text =@"";
            }
        }
    }
    
    
    //translate telephone number
    else if (translateModel == 2){
        
        //add numbers
        if (range.length == 0) {
            temString = [textField.text stringByAppendingString:string];
            
            NSString *regex = @"^\\d{1,10}$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL isMatch = [predicate evaluateWithObject:temString];
            
            if (isMatch) {
                self.typeString = temString;
//                [self translateTele];修改6
             showText.text = [Transform translateNumberWithString:self.typeString model:translateModel];
                
            }
            else{
                returnValue = NO;
            }
            
        }
        else{
            //delete numbers
            if ([textField.text length] > range.length) {
                temString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
                self.typeString = temString;
//                [self translateTele];修改7
               showText.text = [Transform translateNumberWithString:self.typeString model:translateModel];
                
            }
            else{
                showText.text = @"";
            }
        }
    }
    
    returnValue = YES;
    if (returnValue == NO) {
        return NO;
    }
    else {
        self.typeString = temString;
        return YES;
    }
}



#pragma mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
