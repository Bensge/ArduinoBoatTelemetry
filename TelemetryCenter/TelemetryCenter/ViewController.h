//
//  ViewController.h
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCApplication.h"
#import "TCMessageParser.h"
#import "BTCommon.hpp"
#import "MIDIController.h"

@interface ViewController : UIViewController <MIDIControllerDelegate>
- (void)type:(char)c;
- (void)parsedMessage:(NSString *)m packet:(struct BTPacket *)p;
@end

