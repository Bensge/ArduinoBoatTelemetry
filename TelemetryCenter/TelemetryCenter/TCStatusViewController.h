//
//  TCStatusViewController.h
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCommon.hpp"
#import "TelemetryCenter-Swift.h"

IB_DESIGNABLE
@interface TCStatusViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nosLabel;
@property (weak, nonatomic) IBOutlet UILabel *hdopLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *minHdop;
@property (weak, nonatomic) IBOutlet UILabel *maxNOSLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *arduVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (weak, nonatomic) TCRecorderViewController *recorderViewController;
- (void)updateWithPacket:(BTPacket)p;
@end
