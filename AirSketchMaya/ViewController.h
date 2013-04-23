//
//  ViewController.h
//  AirSketchMaya
//
//  Created by Beatty, Geoffrey on 4/6/13.
//  Copyright (c) 2013 Germantown Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AbstractActionSheetPicker;
@interface ViewController : UIViewController <NSStreamDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
	NSInputStream	*inputStream;
	NSOutputStream	*outputStream;
    IBOutlet UISlider *simplifySlider;
}


@property (strong, nonatomic) IBOutlet UISlider *simplifySlider;
@property (strong, nonatomic) NSString *ipAddress;
@property (nonatomic) int portNumber;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSArray *brushArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;
@property (strong, nonatomic) IBOutlet UITextField *brushTextField;
@property (strong, nonatomic) IBOutlet UIImageView *brushTextFieldBG;
@property (strong, nonatomic) IBOutlet UIButton *cover;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIImageView *connectCover;

- (IBAction)popupConnect:(id)sender;
- (IBAction)startDraw:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)createCurve:(id)sender;
- (IBAction)selectBrush:(id)sender;
- (IBAction)renderImage:(id)sender;
- (IBAction)startTransform:(id)sender;
- (IBAction)simplifyCurve:(id)sender;
- (IBAction)stopTransform:(id)sender;
- (IBAction)deleteCurve:(id)sender;
- (IBAction)saveScene:(id)sender;

@end
