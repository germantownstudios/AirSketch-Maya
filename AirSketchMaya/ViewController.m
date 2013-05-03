//
//  ViewController.m
//  AirSketchMaya
//
//  Created by Beatty, Geoffrey on 4/6/13.
//  Copyright (c) 2013 Germantown Studios. All rights reserved.
//

#import "ViewController.h"
#import "CoreMotion/CoreMotion.h"
#import "DDAlertPrompt.h"
#import "ActionSheetPicker.h"

@interface ViewController ()

- (void)brushWasSelected:(NSNumber *)selectedIndex element:(id)element;

@end

@implementation ViewController

@synthesize inputStream;
@synthesize outputStream;
@synthesize ipAddress;
@synthesize portNumber;
@synthesize brushTextField = _brushTextField;
@synthesize brushArray = _brushArray;
@synthesize selectedIndex = _selectedIndex;
@synthesize actionSheetPicker = _actionSheetPicker;
@synthesize simplifySlider;
@synthesize brushTextFieldBG;
@synthesize cover;
@synthesize connectButton;
@synthesize connectCover;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.brushArray = [NSArray arrayWithObjects:@"blue neon", @"red oil", @"orange pastel", @"black charcoal", @"yellow yarn", @"ballpoint pen", @"red ink", @"orange oil", @"green drybrush", @"none", nil];
    
    //set initial brush type
    _brushTextField.text = @"blue neon";
    
    //custom slider ("stretchableImageWithLeft..." is deprecated, so find replacement)
    UIImage *minImage = [UIImage imageNamed:@"SliderMinBG.png"];
    UIImage *maxImage = [UIImage imageNamed:@"SliderMaxBG.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"SliderThumb.png"];
    
    minImage = [minImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    maxImage = [maxImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    
    [self.simplifySlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.simplifySlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [self.simplifySlider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (CMMotionManager *)motionManager {
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

- (void)startMyMotionDetect {
    
    self.motionManager.deviceMotionUpdateInterval = .08;
    
    //declare variables
    __block float time;
    __block float timeOld;
    __block float velX = 0;
    __block float velXNew;
    __block float accelX;
    __block float velY = 0;
    __block float velYNew;
    __block float accelY;
    __block float velZ = 0;
    __block float velZNew;
    __block float accelZ;
    __block BOOL firstTime = TRUE;
       
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //get time
            if (firstTime == TRUE) {
                time = 0.08;
                firstTime = FALSE;
            } else {
                time = data.timestamp - timeOld;
            }
            
            //set acceleration (clip low values)
            accelX = data.userAcceleration.x;
            accelY = data.userAcceleration.y;
            accelZ = data.userAcceleration.z;
            
            if (fabs(accelX) < 0.1) {
                accelX = 0;
            }
            if (fabs(accelY) < 0.1) {
                accelY = 0;
            }
            if (fabs(accelZ) < 0.1) {
                accelZ = 0;
            }
            
            //calculate velocity (set constant velocity to 0)
            velXNew = accelX * -10 * time + velX;
            velYNew = accelY * 5 * time + velY; //Y is reversed for some reason
            velZNew = accelZ * -10 * time + velZ;
            
            if (fabs(velXNew - velX) < 0.1) {
                velXNew = 0;
            }
            if (fabs(velYNew - velY) < 0.1) {
                velYNew = 0;
            }
            if (fabs(velZNew - velZ) < 0.1) {
                velZNew = 0;
            }
            
            //send move command to Maya (note Z and Y are switched due to the way most people hold their phones)
            NSString *response = [NSString stringWithFormat:@"cmds.move(%.02f,%.02f,%.02f, os=True, r=True)", velXNew, velZNew, velYNew];
            NSData *message = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
            [outputStream write:[message bytes] maxLength:[message length]];
                                          
            //increment
            velX = velXNew;
            velY = velYNew;
            velZ = velZNew;
            timeOld = data.timestamp;

        });
    }];
}

- (void)startTransformDetect {
    
    self.motionManager.deviceMotionUpdateInterval = .08;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float rotateX = (data.attitude.pitch * 57.295);
            float rotateY = (data.attitude.yaw * 57.295);
            float rotateZ = (data.attitude.roll * -57.295);
            
            //send rotate command to Maya
            NSString *response = [NSString stringWithFormat:@"cmds.rotate(%.02f,%.02f,%.02f, cp=True)", rotateX, rotateY, rotateZ];
            NSData *message = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
            [outputStream write:[message bytes] maxLength:[message length]];
        });
    }];
}

- (void) initNetworkCommunication {
    
    //create streams and use variables to populate connection method
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(self.ipAddress), self.portNumber, &readStream, &writeStream);
	inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    //send initial message to Maya
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.headsUp()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
    
    //need some error checking or timeout mechanism
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:{
			//NSLog(@"Stream opened");
            [UIView animateWithDuration:0.5 animations:^{
                                 CGAffineTransform coverSlide = CGAffineTransformMakeTranslation(0, 130);
                                 cover.transform = coverSlide;}];
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform connectSlide = CGAffineTransformMakeTranslation(225, 0);
                connectCover.transform = connectSlide;}];
            NSString *connectionAddress = [NSString stringWithFormat:@"connected to Maya (%@:%d)", ipAddress, portNumber];
            [connectButton setTitle:connectionAddress forState:UIControlStateNormal];
        }
			break;
            
		case NSStreamEventHasBytesAvailable:
        if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                           // NSLog(@"Maya said: %@", output);
                        }
                    }
                }
        }
            break;
            
		case NSStreamEventErrorOccurred:
			//NSLog(@"StreamEventError");
            [self connectError];
			break;
            
		case NSStreamEventEndEncountered:
			//NSLog(@"StreamEventEnd");
            [self connectError];
			break;
            
		default:
			break;
	}
}

- (void)hideImages:(UIView *)image {
    image.hidden = YES;
}

- (void)showImages:(UIView *)image {
    image.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)popupConnect:(id)sender {
	DDAlertPrompt *loginPrompt = [[DDAlertPrompt alloc] initWithTitle:@"connect to Maya" delegate:self cancelButtonTitle:@"cancel" otherButtonTitle:@"connect"];
	[loginPrompt show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
	} else {
		if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
			DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
            
            self.ipAddress = loginPrompt.plainTextField.text;
            self.portNumber = [loginPrompt.secretTextField.text intValue];
            
            [self initNetworkCommunication];
		}
	}
}

- (void)connectError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"AirSketch:Maya is unable to connect to Maya. Please make sure you have installed and launched the AirSketch script, and that you have correctly set the ip address and port number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform coverSlide = CGAffineTransformMakeTranslation(0, 0);
        cover.transform = coverSlide;}];
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform connectSlide = CGAffineTransformMakeTranslation(0, 0);
        connectCover.transform = connectSlide;}];
    [connectButton setTitle:@"connect" forState:UIControlStateNormal];
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
		DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
		[loginPrompt.plainTextField becomeFirstResponder];
		[loginPrompt setNeedsLayout];
	}
}

- (IBAction)startDraw:(id)sender {
    //create locator as drawing "cursor"
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.createLoc()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
    
    //start sending deviceMotion
    [self startMyMotionDetect];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform slide = CGAffineTransformMakeTranslation(0, 130);
        cover.transform = slide;}];
    
    [self.simplifySlider setValue:1];
    _brushTextField.text = @"blue neon";
    
}

- (IBAction)startRecord:(id)sender {
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:.04 target:self selector:@selector(sendRecord) userInfo:nil repeats:YES];
}

- (void)sendRecord {
    //send record commands
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.recordMotion()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
}

- (IBAction)stopRecord:(id)sender {
    //stop timer
    [recordTimer invalidate];
    
    //stop sending deviceMotion
    [self.motionManager stopDeviceMotionUpdates];
    
    //send record commands
    NSString *initResponse = [NSString stringWithFormat:@"import maya.cmds as cmds\nimport AirSketch as air\nair.stopRecord()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGAffineTransform slide = CGAffineTransformMakeTranslation(0, 360);
        cover.transform = slide;}];
    
}

- (IBAction)selectBrush:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"select brush" rows:self.brushArray initialSelection:self.selectedIndex target:self successAction:@selector(brushWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (void)brushWasSelected:(NSNumber *)selectedIndex element:(id)element {
    self.selectedIndex = [selectedIndex intValue];
    
    //send brush index
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.attachBrush(%d)", self.selectedIndex];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.brushTextField.text = [self.brushArray objectAtIndex:self.selectedIndex];
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

- (IBAction)renderImage:(id)sender {
    //send render command
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.renderImage()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
}

- (IBAction)startTransform:(id)sender {
    //start transforming curve
    [self startTransformDetect];
}

- (IBAction)simplifyCurve:(id)sender {
    
    UISlider *slider = (UISlider *) sender;
    int stepValue = (int)((slider.maximumValue+1)-slider.value);
    
    //send simplify command
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.simplifyCurve(%d)", stepValue];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
    
}

- (IBAction)stopTransform:(id)sender {
    //stop sending deviceMotion
    [self.motionManager stopDeviceMotionUpdates];
}

- (IBAction)deleteCurve:(id)sender {
       
    //send delete curve command
    NSString *initResponse = [NSString stringWithFormat:@"import AirSketch as air\nair.deleteCurve()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
}

- (IBAction)undo:(id)sender {
    
    //send undo command
    NSString *initResponse = [NSString stringWithFormat:@"import maya.cmds as cmds\ncmds.undo()"];
    NSData *initData = [[NSData alloc] initWithData:[initResponse dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[initData bytes] maxLength:[initData length]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.motionManager stopDeviceMotionUpdates];
}

@end
