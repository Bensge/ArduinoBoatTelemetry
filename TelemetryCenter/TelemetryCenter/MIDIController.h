//
//  MIDIController.h
//  TelemetryCenter
//
//  Created by Benno Krauss on 01/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCommon.hpp"


@protocol MIDIControllerDelegate
- (void)parsedPacket:(BTPacket)p;
@end


@interface MIDIController : NSObject
@property (weak, nonatomic) id <NSObject, MIDIControllerDelegate> delegate;
@end
