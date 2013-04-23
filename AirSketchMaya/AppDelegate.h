//
//  AppDelegate.h
//  AirSketchMaya
//
//  Created by Beatty, Geoffrey on 4/6/13.
//  Copyright (c) 2013 Germantown Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMotion/CoreMotion.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    CMMotionManager *motionManager;
    
}

@property (weak, readonly) CMMotionManager *motionManager;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
