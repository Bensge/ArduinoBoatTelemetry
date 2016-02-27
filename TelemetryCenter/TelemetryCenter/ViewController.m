//
//  ViewController.m
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import "ViewController.h"
#import "TCMessageParser.h"
#import "TCStatusViewController.h"
#import "TelemetryCenter-Swift.h"
@import GoogleMaps;

@interface ViewController () <BTControllerDelegate>
@property (weak) IBOutlet TCStatusViewController *statusViewController;
@property (weak) IBOutlet TCChartsViewController *chartsViewController;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property struct BTPacket lastPacket;
@property (strong, nonatomic) GMSMarker *marker;
@property (strong) GMSMutablePath *path;
@property (strong) GMSPolyline *pathLine;
@end

@implementation ViewController {
	TCMessageParser *parser;
	MIDIController *midiController;
	BTController *btController;
}

static id _self = nil;
+ (id)_self
{
	return _self;
}

- (void)loadView
{
	_self = self;
	NSLog(@"GM API Key valid=%@",[GMSServices provideAPIKey:@"AIzaSyCls8lbrjGO6B4-KgR3BxOIFnkW0rtyZO0"] ? @"YES" : @"NO");
	
	[super loadView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.596039 longitude:9.551930 zoom:20];
	self.mapView.camera = camera;
	self.mapView.mapType = kGMSTypeHybrid;
	
	self.marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(0, 0)];
	self.marker.icon = [UIImage imageWithCGImage:[UIImage imageNamed:@"genesis"].CGImage scale:8 orientation:UIImageOrientationUp];
	self.marker.groundAnchor = CGPointMake(0.5, 0.5);
	self.marker.rotation = 0;
	//self.marker.snippet = @"Boat";
	self.marker.map = self.mapView;
	
	self.path = [GMSMutablePath path];
	self.pathLine = [GMSPolyline polylineWithPath:self.path];
	self.pathLine.strokeColor = UIColor.redColor;
	self.pathLine.strokeWidth = 5;
	self.pathLine.map = self.mapView;
	
	midiController = [[MIDIController alloc] init];
	midiController.delegate = self;
	
	btController = [[BTController alloc] initWithDelegate:self];
	[btController run];
}

- (void)type:(char)c
{
	//NSLog(@"type: %c",c);
	//[parser parse:c];
}

- (void)parsedPacket:(BTPacket)packet
{
	NSLog(@"parsedPacket: ");
	if (packet.hdop < 9999 && lroundf(packet.latitude) != 0 && lroundf(packet.longitude) != 0)
	{
		[self.path addLatitude:packet.latitude longitude:packet.longitude];
		self.pathLine.path = self.path;
		
		self.marker.position = CLLocationCoordinate2DMake(packet.latitude, packet.longitude);
		self.marker.rotation = packet.course;
	}
	
	[self.chartsViewController packetReceived:packet];
	
//	BTPacket p2 = {
//		5,
//		300,
//		1.2,
//		9.551878,
//		47.595963,
//		410.4,
//		123,
//		45
//	};
//	
//	[self.chartsViewController packetReceived:p2];
	[self.statusViewController updateWithPacket:packet];
	
	[self.statusViewController.recorderViewController packetReceived:packet];
	
	//[self.chartsViewController packetReceived:btSamplePacket];
	
	//[self.chartsViewController packetReceived:btSamplePacket2];
	
	//[self.chartsViewController packetReceived:btSamplePacket3];
	//memcpy(&_lastPacket, &packet, sizeof(struct BTPacket));
	self.lastPacket = packet;
}

- (void)prepareForInterfaceBuilder
{
	[self parsedPacket:btSamplePacket];
	[self parsedPacket:btSamplePacket2];
	[self parsedPacket:btSamplePacket3];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	NSLog(@"orient: %@",UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? @"YES" : @"NO");
	self.mapView.hidden = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)parsedMessage:(NSString *)me packet:(struct BTPacket *)packet
{
//	[self.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@" <=> "]];
//	[self.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:me]];
//	[self.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
//	self.textView.selectedRange = NSMakeRange(self.textView.text.length, 0);
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"statusViewControllerSegue"])
	{
		self.statusViewController = segue.destinationViewController;
	}
	else if ([segue.identifier isEqualToString:@"chartsViewControllerSegue"])
	{
		self.chartsViewController = segue.destinationViewController;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
