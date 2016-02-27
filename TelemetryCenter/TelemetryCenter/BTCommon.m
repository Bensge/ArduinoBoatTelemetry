//
//  BTCommon.c
//  TelemetryCenter
//
//  Created by Benno Krauss on 12.02.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//
#include <stdio.h>
#import <Foundation/Foundation.h>
#import "BTCommon.hpp"

void BTPacketPrintDescription(struct BTPacket *packet)
{
	struct BTPacket p = *packet;
	NSLog(@"<BTPacket\nNOS=%u\ntime=%02d:%02d:%02d:%02d\nspeed=%.2fkm/h\nlng=%.6f\nlat=%.6f\nalt=%.1fm\nhdop=%i\ncourse=%.f°\ntemperature=%.1f°C\nmainVoltage=%.2fV\narduinoVoltage=%.2fV\n>\n",
		  p.numberOfSatellites,
		  p.time / 1000000,(p.time / 10000) % 100,(p.time / 100) % 100,p.time % 100,
		  p.speed,
		  p.longitude,
		  p.latitude,
		  p.altitude,
		  p.hdop,
		  p.course,
		  p.temperature,
		  p.mainVoltage,
		  p.arduinoVoltage
	);
}

uint64_t BTPacketGetTimeCentiseconds(struct BTPacket *packet)
{
	uint32_t t = packet->time;
	return (t % 100) + ((t / 100) % 100) * 100 + ((t / 10000) % 100) * 6000 + ((t / 1000000) % 100) * 360000;
}