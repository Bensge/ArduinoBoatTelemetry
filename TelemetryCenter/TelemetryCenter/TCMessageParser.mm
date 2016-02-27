//
//  TCMessageParser.m
//  TelemetryCenter
//
//  Created by Benno Krauss on 19/12/15.
//  Copyright © 2015 Benno Krauss. All rights reserved.
//

#import "TCMessageParser.h"
#import "BTCommon.hpp"

@implementation TCMessageParser
{
	int currentBufferIdxDouble;
	unsigned char currentBuffer[sizeof(struct BTPacket)];
}

void init(TCMessageParser *self)
{
	self->currentBufferIdxDouble = 0;
	memset(self->currentBuffer, 0, sizeof(self->currentBuffer));
}

- (instancetype)init
{
	if (self = [super init])
	{
		init(self);
	}
	return self;
}

- (void)parse:(char)c
{
	NSLog(@"Parsing: %c IDX=%i",c,currentBufferIdxDouble);
	if (c == btPacketDelimiter || c == 'g' || c == 'G')
	{
		struct BTPacket *p = (struct BTPacket *)&currentBuffer;
		[self sendPacket:p];
		
		init(self);
	}
	else
	{
		if (currentBufferIdxDouble / 2 >= sizeof(currentBuffer))
		{
			NSLog(@"Buffer overflow in TCMessageParser!!");
		}
		else
		{
			currentBuffer[currentBufferIdxDouble / 2] |= [self nibbleFromHexChar:c] << (currentBufferIdxDouble % 2 == 0 ? 4 : 0);
			currentBufferIdxDouble += 1;
		}
	}
}

- (unsigned char)nibbleFromHexChar:(char)c
{
	switch (c)
	{
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		case 'A':
		case 'a':
			return 0xA;
		case 'B':
		case 'b':
			return 0xB;
		case 'C':
		case 'c':
			return 0xC;
		case 'D':
		case 'd':
			return 0xD;
		case 'E':
		case 'e':
			return 0xE;
		case 'F':
		case 'f':
			return 0xF;
		default:
			return 0;
	}
}

- (void)sendPacket:(struct BTPacket *)packet
{
	NSString *s = [NSString stringWithFormat:@"BTPacket [ NOS=%i time=%u speed=%f lat=%f lng=%f ]",packet->numberOfSatellites,packet->time,packet->speed,packet->latitude,packet->longitude];
	//NSLog(@"%@",s);
	
	[self.delegate parsedMessage:s packet:packet];
}

@end
