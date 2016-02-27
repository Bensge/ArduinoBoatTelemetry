//
//  main.m
//  TCTester
//
//  Created by Benno Krauss on 10.02.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCommon.hpp"
#import <CoreMIDI/CoreMIDI.h>

MIDIPortRef port;
MIDIClientRef client;

int position;
Byte packet[sizeof(BTPacket)];

void tryConnectMIDISource();

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		
		position = 0;
		MIDIClientCreateWithBlock(CFSTR("Arduino"), &client, ^(const MIDINotification * _Nonnull message) {
			//NSLog(@"MIDIDI message: %i",message->messageID);
			
			switch (message->messageID)
			{
				case kMIDIMsgPropertyChanged:
				{
					MIDIObjectPropertyChangeNotification *noti = (MIDIObjectPropertyChangeNotification *)message;
					NSLog(@"Property changed: %@",noti->propertyName);
					
					break;
				}
				case kMIDIMsgObjectAdded:
				{
					MIDIObjectAddRemoveNotification *noti = (MIDIObjectAddRemoveNotification *)message;
					NSLog(@"Object added: %u of type: %i",noti->child,noti->childType);
					
					if (noti->childType == kMIDIObjectType_Source)
					{
						tryConnectMIDISource();
					}
				}
				case kMIDIMsgObjectRemoved:
				default:
					break;
			}
		});
		
		MIDIInputPortCreateWithBlock(client, CFSTR("Input"), &port, ^(const MIDIPacketList * _Nonnull packetList, void * _Nullable srcConnRefCon)
									 {
										 dispatch_sync(dispatch_get_main_queue(), ^
													   {
														   const MIDIPacket *p = &packetList->packet[0]; //gets first packet in list
														   
														   for (unsigned int i = 0; i < packetList->numPackets; i++)
														   {
															   UInt16 nBytes = p->length; //number of bytes in a packet
															   
															   //NSLog(@"MIDIDI Got packet!!!");
															   //NSLog(@"Packet length=%u",nBytes);
															   
															   if (nBytes % 3 == 0)
															   {
																   int offset = 0;
																   for (int j = 0; j < nBytes / 3; j++)
																   {
																	   //NSLog(@"{ %i %i %i }",p->data[0],p->data[1],p->data[2]);
																	   for (int i = 0; i < 3; i++)
																	   {
																		   packet[position++] = p->data[i + offset];
																		   //NSLog(@"position=%i",position);
																		   if (position == sizeof(BTPacket))
																		   {
																			   position = 0;
																			   
																			   BTPacket newPacket;
																			   memcpy(&newPacket, packet, sizeof(BTPacket));
																			   
																			   newPacket.printDescription();
																			   
																			   //[self.delegate parsedPacket:newPacket];
																			   
																			   break;
																		   }
																	   }
																	   offset++;
																   }
															   }
															   else {
																   NSLog(@"Packet has %u bytes instead of a multiple of 3!!!",nBytes);
															   }
															   
															   p = MIDIPacketNext(p);
														   }
													   });
									 });
		
		tryConnectMIDISource();
	}
	
	[[NSRunLoop mainRunLoop] run];
	
    return 0;
}

void tryConnectMIDISource()
{
	for (int i = 0; i < MIDIGetNumberOfSources(); i++)
	{
		MIDIEndpointRef source = MIDIGetSource(i);
		
		CFStringRef sourceName;
		MIDIObjectGetStringProperty(source, kMIDIPropertyName, &sourceName);
		NSLog(@"MIDIDI: Connecting to device %@",sourceName);
		
		MIDIPortConnectSource(port, source, NULL);
	}
}
