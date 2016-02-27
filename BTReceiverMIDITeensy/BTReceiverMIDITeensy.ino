//Created 09.12.2015
//Bennos Telemetry Receiver Sketch

#include <SPI.h>
#include "RF24.h"
#include <Wire.h> 
#include <BTCommon.h>


#define __THROTTLER(n) throttler_##n
#define _THROTTLER(n) __THROTTLER(n)
#define _callEvery(INTERVAL,__COUNT,BLOCK) static unsigned long _THROTTLER(__COUNT) = 0; \
                      if (millis() - _THROTTLER(__COUNT) >= INTERVAL){ \
                        _THROTTLER(__COUNT) = millis(); \
                        BLOCK \
                      }

#define callEvery(INTERVAL,BLOCK) _callEvery(INTERVAL,__COUNTER__,BLOCK)


//Static variables
RF24 radio(9,10);

const uint64_t pipes[2] = { 0xF0F0F0F0E1LL, 0xF0F0F0F0D2LL };


//Functions
void sendUSBPacket(BTPacket p);

#define satelliteCharID 0
#define clockCharID 1
#define rightArrowCharID 2

void setup()
{
  //PC Logging serial
//  Serial.begin(9600);
  delay(3000);
//  while (!Serial);
//  Serial.println("HI");
  //Serial.print("sizeof(BTPacket) = "); Serial.println(sizeof(BTPacket));
  //printf_begin();
  //nRF24
  radio.begin();
  radio.enableDynamicPayloads();
  radio.setDataRate(RF24_250KBPS);
  radio.setPALevel(RF24_PA_MIN);
  
  //Serial.println("HI");
  radio.openWritingPipe(pipes[1]);
  radio.openReadingPipe(1,pipes[0]);
  //Serial.println("HI");
  radio.startListening();
  //radio.printDetails();
  //printf("Done\n");

  //Serial.println("Done with setup");
}

BTPacket p = {0};
void loop()
{
//    callEvery(500,{
//      Serial.println("Reccing");
//    });
    while (radio.available())
    {
      int len = radio.getDynamicPayloadSize();

      if (len == 32)
      {
        //First 32 Bytes of our BTPacket
        radio.read(&p, 32);
      }
      else if (len == sizeof(BTPacket) - 32)
      {
        radio.read(&p.temperature, len);
      }
      
      sendUSBPacket(&p);
      Serial.println(millis());
    }
}

void sendUSBPacket(BTPacket *p)
{
  uint8_t numberOfBytes = sizeof(BTPacket);
  sendUSB((byte *)p,numberOfBytes);
}

byte message[4];
void sendUSB(byte *buffer, unsigned int length)
{
  unsigned int position = 0;
  
  while (position < length)
  {
    message[0] = 0x0B;
    message[1] = 'g';
    message[2] = 'g';
    message[3] = 'g';
    for (byte i = 0; i < 3; i++)
    {
      message[i + 1] = buffer[position++];

      if (position == length)
        break;
    }

#if defined(CORE_TEENSY)
    usb_midi_write_packed(* (uint32_t*)&message[0] );

    //usb_tx(MIDI_TX_ENDPOINT, tx_packet);
    
    usb_midi_flush_output();
    //while (usbMIDI.read());

#else
    MidiUSB.write(message,sizeof(message));
    MidiUSB.flush();
#endif
  }
  //usbMIDI.send_now();
  //usb_midi_flush_output();
}


