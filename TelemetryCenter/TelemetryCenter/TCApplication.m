//
//  TCApplication.m
//  TelemetryCenter
//
//  Created by Benno Krauss on 19/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import "TCApplication.h"


@interface UIPhysicalKeyboardEvent : /*UIPhysicalButtonsEvent*/NSObject
@property(retain) NSString * _commandModifiedInput;
@property(readonly) long long _gsModifierFlags;
@property int _inputFlags;
@property(readonly) bool _isKeyDown;
@property(readonly) long long _keyCode;
@property(retain) NSString * _markedInput;
@property(retain) NSString * _modifiedInput;
@property long long _modifierFlags;
@property(retain) NSString * _privateInput;
@property(retain) NSString * _shiftModifiedInput;
@property(retain) NSString * _unmodifiedInput;
@end

@interface UIApplication ()
- (void)handleKeyHIDEvent:(void *)event;
- (void)handleKeyUIEvent:(UIPhysicalKeyboardEvent *)event;
@end


@implementation TCApplication

+ (TCApplication *)sharedApplication
{
	return ((TCApplication *)UIApplication.sharedApplication);
}

struct __IOHIDEvent {};


- (void)handleKeyHIDEvent:(/*struct __IOHIDEvent { }*/void *)event
{
	//NSLog(@"handleKeyHIDEvent: %@",event);
	
	[super handleKeyHIDEvent:event];
}

- (void)handleKeyUIEvent:(UIPhysicalKeyboardEvent *)event
{
	NSLog(@"handleKeyUIEvent: %@",event._unmodifiedInput);
	
	if (self.keyboardListener && [self.keyboardListener respondsToSelector:@selector(type:)])
	{
		[self.keyboardListener type:event._unmodifiedInput.UTF8String[0]];
	}
	//else
	[super handleKeyUIEvent:event];
}

@end
