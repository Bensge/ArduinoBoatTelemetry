//
//  TCMessageParser.h
//  TelemetryCenter
//
//  Created by Benno Krauss on 19/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCommon.hpp"

@protocol TCMessageParserDelegate
- (void)parsedMessage:(NSString *)m packet:(struct BTPacket *)p;
@end

@interface TCMessageParser : NSObject
- (void)parse:(char)c;
@property (weak) id <NSObject, TCMessageParserDelegate> delegate;
@end
