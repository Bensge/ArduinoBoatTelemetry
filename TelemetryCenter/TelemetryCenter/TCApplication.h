//
//  TCApplication.h
//  TelemetryCenter
//
//  Created by Benno Krauss on 19/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCKeyboardListener
- (void)type:(char)c;
@end

@interface TCApplication : UIApplication
+ (TCApplication *)sharedApplication;
@property (weak, nonatomic) id <NSObject,TCKeyboardListener> keyboardListener;
@end
