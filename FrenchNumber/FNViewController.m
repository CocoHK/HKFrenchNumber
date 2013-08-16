//
//  ViewController.m
//  FrenchNumber
//
//  Created by Coco on 07/03/13.
//  Copyright (c) 2013 Coco. All rights reserved.
//

#import "FNViewController.h"
@interface FNViewController () {
//    CGRect originalBounds;
    CGRect originalFrame;

}

@property (nonatomic, retain) UIButton *dotButton;

- (IBAction)changeMode:(id)sender;

@end

@implementation FNViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}


- (void)keyboardDidShowNotification:(NSNotification *)notification {
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
//    for(int i=0; i<[tempWindow.subviews count]; i++) {
//        keyboardView = [tempWindow.subviews objectAtIndex:i];
//    }
//        [self addButtonToKeyboard];
    CGRect finalRect;
    originalFrame = self.view.frame;
    NSLog(@"originalFrame is %@",NSStringFromCGRect(originalFrame));

    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSLog(@"kbSize is %@",NSStringFromCGSize(kbSize));
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            finalRect = CGRectMake(originalFrame.origin.x,originalFrame.origin.y,originalFrame.size.width,originalFrame.size.height - kbSize.height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            finalRect = CGRectMake(kbSize.width,originalFrame.origin.y,originalFrame.size.width - kbSize.width,originalFrame.size.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            finalRect = CGRectMake(originalFrame.origin.x,originalFrame.origin.y,originalFrame.size.width - kbSize.width,originalFrame.size.height);
            break;
        default:
            break;
    }
    NSLog(@"Final Rect: %@",NSStringFromCGRect(finalRect));
    self.view.frame = finalRect;

}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    self.view.frame =  originalFrame;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    typeText.layer.cornerRadius = 5.0;
    showText.layer.cornerRadius = 5.0;


    self.positiveInt = [NSCharacterSet characterSetWithCharactersInString:@"123456789"];
    self.point =[NSCharacterSet characterSetWithCharactersInString:@"."];
    
    [self setTranslationMode:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap release];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    NSLog(@"%@",NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]));
    NSLog(@"frame%@",NSStringFromCGRect(self.view.frame));

}


- (void)dismissKeyboard {
    [typeText resignFirstResponder];
}

- (void)setTranslationMode:(int)mode {
    translateModel = mode;
    [self updateKeyboard:mode];

}

- (IBAction)changeMode:(id)sender {
    [self setTranslationMode:((UIButton *)sender).tag];

    NSLog(@"button number is %d",translateModel);
}

- (void)updateKeyboard:(int)currentMode {
    switch (translateModel) {
        case 0:
        case 1:
        {
            [typeText setKeyboardType:UIKeyboardTypeDecimalPad];
        }
            break;
        case 2:
        {
            [typeText setKeyboardType:UIKeyboardTypeNumberPad];

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
    if (translateModel == 0 || translateModel == 1) {
        
        // add numbers
        if (range.length == 0) {
            self.typeString = [textField.text stringByAppendingString:string];
            NSString *regex = @"^\\d*[\\.]?\\d*$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL isMatch = [predicate evaluateWithObject:self.typeString];
            if (isMatch) {
                //judge when the first character is 0
                if ([self.typeString characterAtIndex:0] == '0'&&
                    [self.typeString length] >= 2 &&
                    ([self.typeString characterAtIndex:1] != '.' &&
                     [self.typeString characterAtIndex:1] != ','))
                    isMatch = NO;
            }
            if (isMatch) {
                if ([self.typeString rangeOfCharacterFromSet:self.point].location == NSNotFound){
                    if ([self.typeString length] > 23)
                        isMatch = NO;
                }
                else{
                    int location = [self.typeString rangeOfCharacterFromSet:self.point].location;
                    
                    if (translateModel == 0) {
                        if ([[self.typeString substringToIndex:location] length] > 23 ||
                            [[self.typeString substringFromIndex:location+1] length] > 21)
                            isMatch = NO;
                    }
                    else if (translateModel == 1){
                        if ([[self.typeString substringToIndex:location] length] > 23 ||
                            [[self.typeString substringFromIndex:location+1] length] > 2)
                            
                            isMatch = NO;
                    }
                }
                
            }
            
            
            if (isMatch) {
                [self translateNumber];
            }
            else{
                return NO;
            }
        }
        
        else{
            //delete numbers
            
            if ([textField.text length] > range.length) {
                self.typeString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
                NSLog(@"textfield is %d range is %d string is %@  typestring is %@",[textField.text length],range.length,string,self.typeString);

                [self translateNumber];
                
            }
            else{
                showText.text =@"";
            }}
        
        NSLog(@"typeString is %@",self.typeString);
    }
    
    
    //translate telephone number
    else if (translateModel == 2){
        
        //add numbers
        if (range.length == 0) {
            
            self.typeString = [textField.text stringByAppendingString:string];
            NSString *regex = @"^\\d{1,10}$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            BOOL isMatch = [predicate evaluateWithObject:self.typeString];
            
            if (isMatch) {
                [self translateTele];
                
            }
            else{
                return NO;
            }
            
        }
        else{
            //delete numbers
            if ([textField.text length] > range.length) {
                self.typeString = [textField.text stringByReplacingCharactersInRange:(NSRange)range withString:@""];
                
                [self translateTele];
                
            }
            else{
                showText.text =@"";
            }
        
        NSLog(@"typeString is %@",self.typeString);
        }
    }
    return YES;
}

- (void)translateTele{
    NSMutableString *showString = [[NSMutableString new]autorelease];
    int length = [self.typeString length];
    int index;
    for (index =0; index < length; index = index +2) {
        NSRange subStringRange;
        if (length - index == 1) {
            subStringRange = NSMakeRange(index, 1);
        }
        else {
            subStringRange = NSMakeRange(index, 2);
        }
        NSString *subString = [self.typeString substringWithRange:subStringRange];
        
        [showString appendString:[self getTens:subString]];
        
        
        NSLog(@"typeString is %@",self.typeString);
        
    }
    showText.text = showString;
    
    
}

- (void)translateNumber{
    NSMutableString *showString = [[NSMutableString new]autorelease];
    //there are just intergers
    if ([self.typeString rangeOfCharacterFromSet:self.point].location == NSNotFound) {
        [showString appendString:[self translateInteger:self.typeString]];
    }
    
    //there are decimal numbers
    else{
        NSUInteger location = [self.typeString rangeOfCharacterFromSet:self.point].location;
        NSString *integerString = [self.typeString substringToIndex:location];
        
        //if int exists
        if ([integerString length]>0) {
            //int == 0, like 0,XXXX
            if ([integerString intValue] == 0) {
                if ([[self.typeString substringFromIndex:location+1] rangeOfCharacterFromSet:self.positiveInt].location != NSNotFound) {
                    if (translateModel == 0) {
                        [showString setString:[self translateDecimal:[self.typeString substringFromIndex:location+1]]];
                    }
                    else if (translateModel == 1){
                        [showString setString:[self translateEuroDecimal:[self.typeString substringFromIndex:location+1]]];
                        
                    }
                }
                // 0,0000
                else{
                    [showString setString:@"zéro"];
                }
            }
            
            //int > 0 ,like XXX,XXX
            else{
                [showString appendString:[self translateInteger:integerString]];// vingt-huit...
                
                if ([[self.typeString substringFromIndex:location+1] rangeOfCharacterFromSet:self.positiveInt].location != NSNotFound) {
                    if (translateModel == 0) {
                        [showString appendFormat:@"et %@",[self translateDecimal:[self.typeString substringFromIndex:location+1]]];
                    }
                    else if(translateModel == 1){
                        [showString appendString:[self translateEuroDecimal:[self.typeString substringFromIndex:location+1]]];
                    }
                    
                }
                
            }}
        
        
        else{
            //int doesn't exist
            if ([[self.typeString substringFromIndex:location+1] rangeOfCharacterFromSet:self.positiveInt].location != NSNotFound) {
                if (translateModel == 0) {
                    [showString appendString:[self translateDecimal:[self.typeString substringFromIndex:location+1]]];
                }
                else if (translateModel == 1){
                    [showString appendString:[self translateEuroDecimal:[self.typeString substringFromIndex:location+1]]];
                }
            }
            else{
                [showString setString:@""];
            }
        }
    }
    showText.text = showString;
}




- (NSString *)translateInteger:(NSString*)string
{
    NSMutableString *showString = [[[NSMutableString alloc] initWithString:string] autorelease];
    if ([string length] == 1 && [string isEqualToString: @"0"]) {
        [showString setString: @"zéro "];
    }
    else{
        [showString setString:[self getRemainder:string unitIndex:0]];
        if (translateModel == 1) {
            [showString appendFormat:@"euro%@ ",([showString isEqualToString:@"un  "])?@"":@"s"];
        }
    }
    
    NSLog(@"showString3 is %@",showString);
    return showString;
}

- (NSString *)translateDecimal:(NSString *)decimal{
    NSArray *units = [NSArray arrayWithObjects:@"dixième",@"centième",@"millième",@"dix-millième",@"cent-millième",@"millionième",@"dix-millionième",@"cent-millionième",@"milliardième",@"dix-milliardième",@"cent-milliardième",@"billionième",@"dix-billionième",@"cent-billionième",@"billiardième",@"dix-billiardième",@"cent-billiardième",@"trillionième",@"dix-trillionième",@"cent-trillionième",@"trilliardième",nil];
    NSMutableString *typeDecimal = [[[NSMutableString alloc]initWithString:decimal] autorelease];
    NSMutableString *showString = [[NSMutableString new] autorelease];
    if ([typeDecimal rangeOfCharacterFromSet:self.positiveInt].location != NSNotFound) {
        NSInteger fullLength = [typeDecimal length];
        while (fullLength > 0 && [typeDecimal characterAtIndex:fullLength-1] == '0') {
            [typeDecimal deleteCharactersInRange:NSMakeRange(fullLength-1,1)];
            fullLength--;
        }
        NSInteger subLength = [typeDecimal length];
        while ([typeDecimal characterAtIndex:0] == '0') {
            [typeDecimal deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        [showString appendString:[self getRemainder:typeDecimal unitIndex:0]];
        [showString appendFormat:@"%@%@",[units objectAtIndex:subLength-1],([typeDecimal intValue]> 1)?@"s":@""];
        NSLog(@"subLength:%d  %@",subLength,[units objectAtIndex:subLength-1]);
    }
    else{
        [showString appendString:@""];
    }
    return showString;
}




- (NSString *)getRemainder:(NSString *)partString unitIndex:(int)unitIndex {
    NSArray *units = [NSArray arrayWithObjects:@"",@"mille",@"million",@"milliard",@"billion",@"billiard",@"trillion",@"trilliard", nil];
    NSMutableString *fullString = [[NSMutableString new]autorelease];
    int n = [partString length];
    
    NSString * subString = nil;
    
    if (n > 3) {
        [fullString appendString:[self getRemainder:[partString substringToIndex:n-3] unitIndex:unitIndex + 1]];
        subString = [partString substringFromIndex:n-3];
    }
    else{
        subString = partString;
    }
    
    int remainder = [subString intValue];
    // when 1000, don't translate number
    if (!(remainder == 1 && unitIndex == 1))
        [fullString appendString:[self translateRemainder:remainder]];
    if (remainder > 0)
        [fullString appendString:[NSString stringWithFormat:@"%@%@ ",[units objectAtIndex:unitIndex],(remainder >1 && unitIndex >1)?@"s":@""]];
    return fullString;
}



- (NSString *)translateRemainder:(int)remainder{
    NSMutableString *finalString = [[NSMutableString new] autorelease];
    int quotient = remainder / 100;
    int rmd = remainder % 100;
    if (quotient > 0) {
        //when 100, there is a unnecessary space, should deal it later
        [finalString appendString:[NSString stringWithFormat:@"%@ ",[self getPrefixNumber:quotient]]];
        
        [finalString appendString:[NSString stringWithFormat:@"cent%@ ",(quotient == 1 || rmd != 0)?@"":@"s"]];
    }
    //    [finalString appendString:[self translateTens:rmd]];
    [finalString appendString:[self translateTens:[NSString stringWithFormat:@"%d",rmd]]];
    
    return finalString;
}

- (NSString *)translateEuroDecimal:(NSString *)centime{
    NSMutableString *centimeString = [[NSMutableString new] autorelease];
    if ([centime length] == 1) {
        //        int n = [centime intValue]*10;
        [centimeString appendFormat:@"%@ centimes",[self translateTens:[NSString stringWithFormat:@"%d",[centime intValue]*10]]];
    }
    else{
        //        int a = [centime intValue];
        //        NSLog(@"%d  %@",a,[self translateTens:a]);
        [centimeString appendFormat:@"%@ centime%@",[self translateTens:centime],([centime intValue] >1)?@"s":@""];
        
    }
    
    return centimeString;
}

//keepFirstZero == yes;

//- (NSString *)getTens:(NSString *)tensString keepFirstZero:(BOOL)keepFirstZero {
- (NSString *)getTens:(NSString *)tensString{
    
    NSString *rmdString = nil;
    if ([tensString characterAtIndex:0] == '0') {
        rmdString = @"zéro ";
        NSLog(@"rmdString is %@",rmdString);
        
        if ([tensString length] == 2){
            rmdString = [rmdString stringByAppendingString:[self teleUnitNumber:[[tensString substringFromIndex:1] intValue]]];
            
            NSLog(@"rmdString is %@",rmdString);
            
        }}
    else{
        int tens = [tensString intValue];
        if (tens == 1){
            rmdString = @"un ";
        }
        else if (tens <= 16){
            rmdString = [self getPrefixNumber:tens];
        }
        else if ((tens <= 69 && tens > 16) ||(tens >= 80 && tens < 90)){
            int units = tens % 10;
            NSString *unitString = [self getUnits:units];
            if (tens < 20 && tens > 16) {
                rmdString = [NSString stringWithFormat:@"dix%@",unitString];
            }
            if (tens < 30 && tens >= 20) {
                rmdString = [NSString stringWithFormat:@"vingt%@",unitString];
            }
            if (tens < 40 && tens >= 30) {
                rmdString = [NSString stringWithFormat:@"trente%@",unitString];
            }
            if (tens < 50 && tens >= 40) {
                rmdString = [NSString stringWithFormat:@"quarante%@",unitString];
            }
            if (tens < 60 && tens >= 50) {
                rmdString = [NSString stringWithFormat:@"cinquante%@",unitString];
            }
            if (tens <= 69 && tens >= 60) {
                rmdString = [NSString stringWithFormat:@"soixante%@",unitString];
            }
            if (tens == 80) {
                rmdString = @"quatre-vingts ";
            }
            if (tens == 81) {
                rmdString = @"quatre-vingt-un ";
            }
            if (tens > 81 && tens < 90) {
                rmdString = [NSString stringWithFormat:@"quatre-vingt%@",unitString];
            }
        }
        else if ((tens <= 79 && tens >= 70)||(tens <= 99 && tens >= 90)){
            int units = tens % 10;
            NSString *unitString = [self getUnitsException:units];
            if (tens <= 79 && tens >= 70) {
                rmdString = [NSString stringWithFormat:@"soixante%@",unitString];
            }
            if (tens <= 99 && tens >= 90) {
                rmdString = [NSString stringWithFormat:@"quatre-vingt%@",unitString];
            }
        }
        
    }
    return rmdString;
    
}

//keepFirstZero == no;
- (NSString *)translateTens:(NSString *)tensString {
    //    - (NSString *)translateTens:(NSString *)tensString keepFirstZero:(BOOL)keepFirstZero {
    
    NSString *rmdString = @"";
    int tens = [tensString intValue];
    if (tens == 0){
        rmdString = @"";
    }
    else if (tens == 1){
        rmdString = @"un ";
    }
    else if (tens <= 16){
        rmdString = [self getPrefixNumber:tens];
    }
    else if ((tens <= 69 && tens > 16) ||(tens >= 80 && tens < 90)){
        int units = tens % 10;
        NSString *unitString = [self getUnits:units];
        if (tens < 20 && tens > 16) {
            rmdString = [NSString stringWithFormat:@"dix%@",unitString];
        }
        if (tens < 30 && tens >= 20) {
            rmdString = [NSString stringWithFormat:@"vingt%@",unitString];
        }
        if (tens < 40 && tens >= 30) {
            rmdString = [NSString stringWithFormat:@"trente%@",unitString];
        }
        if (tens < 50 && tens >= 40) {
            rmdString = [NSString stringWithFormat:@"quarante%@",unitString];
        }
        if (tens < 60 && tens >= 50) {
            rmdString = [NSString stringWithFormat:@"cinquante%@",unitString];
        }
        if (tens <= 69 && tens >= 60) {
            rmdString = [NSString stringWithFormat:@"soixante%@",unitString];
        }
        if (tens == 80) {
            rmdString = @"quatre-vingts ";
        }
        if (tens == 81) {
            rmdString = @"quatre-vingt-un ";
        }
        if (tens > 81 && tens < 90) {
            rmdString = [NSString stringWithFormat:@"quatre-vingt%@",unitString];
        }
    }
    else if ((tens <= 79 && tens >= 70)||(tens <= 99 && tens >= 90)){
        int units = tens % 10;
        NSString *unitString = [self getUnitsException:units];
        if (tens <= 79 && tens >= 70) {
            rmdString = [NSString stringWithFormat:@"soixante%@",unitString];
        }
        if (tens <= 99 && tens >= 90) {
            rmdString = [NSString stringWithFormat:@"quatre-vingt%@",unitString];
        }
    }
    
    return rmdString;
    
}


- (NSString *)getPrefixNumber:(int)remainder{
    NSString *rmdString = nil;
    if (remainder > 0 && remainder <= 16) {
        switch (remainder) {
            case 1:
                rmdString = @"";
                break;
            case 2:
                rmdString = @"deux ";
                break;
            case 3:
                rmdString = @"trois ";
                break;
            case 4:
                rmdString = @"quatre ";
                break;
            case 5:
                rmdString = @"cinq ";
                break;
            case 6:
                rmdString = @"six ";
                break;
            case 7:
                rmdString = @"sept ";
                break;
            case 8:
                rmdString = @"huit ";
                break;
            case 9:
                rmdString = @"neuf ";
                break;
            case 10:
                rmdString = @"dix ";
                break;
            case 11:
                rmdString = @"onze ";
                break;
            case 12:
                rmdString = @"douze ";
                break;
            case 13:
                rmdString = @"treize ";
                break;
            case 14:
                rmdString = @"quatorze ";
                break;
            case 15:
                rmdString = @"quinze ";
                break;
            case 16:
                rmdString = @"seize ";
                break;
            default:
                
                break;
        }
    }
    return rmdString;
}

- (NSString *)teleUnitNumber:(int)unit{
    NSString *rmdString = nil;
    if (unit >= 0 && unit < 10) {
        switch (unit) {
            case 0:
                rmdString = @"zéro ";
                break;
            case 1:
                rmdString = @"un ";
                break;
            case 2:
                rmdString = @"deux ";
                break;
            case 3:
                rmdString = @"trois ";
                break;
            case 4:
                rmdString = @"quatre ";
                break;
            case 5:
                rmdString = @"cinq ";
                break;
            case 6:
                rmdString = @"six ";
                break;
            case 7:
                rmdString = @"sept ";
                break;
            case 8:
                rmdString = @"huit ";
                break;
            case 9:
                rmdString = @"neuf ";
                break;
            default:
                
                break;
        }
    }
    return rmdString;
}


- (NSString *)getUnits:(int)u{
    NSString *unitsString = @" ";
    switch (u) {
        case 1:
            unitsString = @" et un ";
            break;
        case 2:
            unitsString = @"-deux ";
            break;
        case 3:
            unitsString = @"-trois ";
            break;
        case 4:
            unitsString = @"-quatre ";
            break;
        case 5:
            unitsString = @"-cinq ";
            break;
        case 6:
            unitsString = @"-six ";
            break;
        case 7:
            unitsString = @"-sept ";
            break;
        case 8:
            unitsString = @"-huit ";
            break;
        case 9:
            unitsString = @"-neuf ";
            break;
        default:
            
            break;
    }
    return unitsString;
}

- (NSString *)getUnitsException:(int)u{
    NSString *unitsString = @" ";
    switch (u) {
        case 0:
            unitsString = @"-dix ";
            break;
        case 1:
            unitsString = @" et onze ";
            break;
        case 2:
            unitsString = @"-douze ";
            break;
        case 3:
            unitsString = @"-treize ";
            break;
        case 4:
            unitsString = @"-quatorze ";
            break;
        case 5:
            unitsString = @"-quinze ";
            break;
        case 6:
            unitsString = @"-seize ";
            break;
        case 7:
            unitsString = @"-dix-sept ";
            break;
        case 8:
            unitsString = @"-dix-huit ";
            break;
        case 9:
            unitsString = @"-dix-neuf ";
            break;
        default:
            break;
    }
    return unitsString;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
