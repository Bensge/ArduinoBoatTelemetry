//
//  TCStatusViewController.m
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

#import "TCStatusViewController.h"
@import CoreText;

@interface TCStatusViewController ()

@end

@implementation TCStatusViewController {
	float maxSpeed;
	int minHDOP;
	int maxNOS;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		minHDOP = 9999;
	}
	return self;
}

- (void)updateWithPacket:(BTPacket)p
{
	if (p.speed > maxSpeed)
		maxSpeed = p.speed;
	
	if (p.hdop < minHDOP)
		minHDOP = p.hdop;
	
	if (p.numberOfSatellites > maxNOS)
		maxNOS = p.numberOfSatellites;
	
	
	self.speedLabel.text = [NSString stringWithFormat:@"Speed: %.2fkm/h",p.speed];
	self.nosLabel.text = [NSString stringWithFormat:@"NOS: %i📡",p.numberOfSatellites];
	self.hdopLabel.text = [NSString stringWithFormat:@"HDOP: %i",p.hdop];
	self.timeLabel.text = [NSString stringWithFormat:@"🕑 %02d:%02d:%02d:%02d",p.time / 1000000,(p.time / 10000) % 100,(p.time / 100) % 100,p.time % 100];
	self.altitudeLabel.text = [NSString stringWithFormat:@"Alt: %.1fm",p.altitude];
	
	self.voltageLabel.text = [NSString stringWithFormat:@"U: %.2fV",p.mainVoltage];
	
	self.temperatureLabel.text = [NSString stringWithFormat:@"ϑ: %.1f℃",p.temperature];

	NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Speedmax: %.2fkm/h",maxSpeed]];
	[temp beginEditing];
	[temp addAttributes:@{ (__bridge NSString *)kCTSuperscriptAttributeName : @-0.8, (__bridge NSString *)kCTFontAttributeName : [UIFont boldSystemFontOfSize:self.maxSpeedLabel.font.pointSize / 1.8] } range:NSMakeRange(5, 3)];
	[temp endEditing];
	self.maxSpeedLabel.attributedText = temp;
	
	temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"HDOPmin: %i",minHDOP]];
	[temp setAttributes:@{ (__bridge NSString *)kCTSuperscriptAttributeName : @-0.8, NSFontAttributeName : [UIFont boldSystemFontOfSize:self.minHdop.font.pointSize / 1.8] } range:NSMakeRange(4, 3)];
	self.minHdop.attributedText = temp;

	temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"NOSmax: %i📡",maxNOS]];
	[temp setAttributes:@{ (__bridge NSString *)kCTSuperscriptAttributeName : @-0.8, NSFontAttributeName : [UIFont boldSystemFontOfSize:self.maxNOSLabel.font.pointSize / 1.8] } range:NSMakeRange(3, 3)];
	self.maxNOSLabel.attributedText = temp;
	
	temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Uardu: %.2fV",p.arduinoVoltage]];
	[temp setAttributes:@{ (__bridge NSString *)kCTSuperscriptAttributeName : @-0.8, NSFontAttributeName : [UIFont boldSystemFontOfSize:self.arduVoltageLabel.font.pointSize / 1.8] } range:NSMakeRange(1, 4)];
	self.arduVoltageLabel.attributedText = temp;
}

- (void)prepareForInterfaceBuilder
{
	NSLog(@"HI++++++++++++++++++++++++++++++++++++");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	dispatch_async(dispatch_get_main_queue(),^{
		[self updateWithPacket:btNullPacket];
	});
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"recordingViewController"])
	{
		self.recorderViewController = (TCRecorderViewController *)segue.destinationViewController;
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
