//
//  ControlSoundViewController.h
//  playground
//
//  Created by Kevin Liang on 11/18/14.
//  Copyright (c) 2014 Wonder Workshop. All rights reserved.
//

#import "RobotControlViewController.h"

@interface ControlSoundViewController : RobotControlViewController

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

- (IBAction)playSoundPressed:(id)sender;

@end
