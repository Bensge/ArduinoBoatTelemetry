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

#define ftostr(f,strname,precision) char strname[12]; dtostrf(f,precision + 2,precision,strname);


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
  Serial.begin(9600);
  Serial1.begin(115200);
  delay(3000);
  //nRF24
  radio.begin();
  radio.enableDynamicPayloads();
  radio.setDataRate(RF24_250KBPS);
  //radio.setPALevel(RF24_PA_MAX);
  
  Serial.println("HI");
  radio.openWritingPipe(pipes[1]);
  radio.openReadingPipe(1,pipes[0]);
  //Serial.println("HI");
  radio.startListening();
  radio.printDetails();
  //printf("Done\n");

  //Serial.println("Done with setup");
}

BTPacket p = {0};
void loop()
{
//    callEvery(500,{
//      Serial.println("Reccing");
//    });

    checkBTConnection();

    while (radio.available())
    {
      int len = radio.getDynamicPayloadSize();
      Serial.print("Got p");
      if (len == 32)
      {
        //First 32 Bytes of our BTPacket
        radio.read(&p, 32);
      }
      else if (len == sizeof(BTPacket) - 32)
      {
        radio.read(&p.temperature, len);
      }

      sendBTPacket(&p);
      //sendUSBPacket(&p);
      Serial.println(millis());
    }
}

bool btConnected = false;
uint8_t btConnectionPos = 0;
uint8_t btLostPos = 0;

void checkBTConnection()
{
  while (Serial1.available())
  {
    char c = Serial1.read();
    if (c == "OK+CONN"[btConnectionPos])
    {
      btConnectionPos++;
      if (btConnectionPos == 7)
      {
        btConnected = true;
        Serial.print("Connected");
      }
    }
    else
      btConnectionPos = 0;


    if (c == "OK+LOST"[btLostPos])
    {
      btLostPos++;
      if (btLostPos == 7)
      {
        btConnected = false;
        Serial.print("Disconnected");
      }
    }
    else
      btLostPos = 0;
  }
}

void sendBTPacket(BTPacket *packet)
{
  if (!btConnected) return;
  
  BTPacket p = *packet;
  char buf[512];
  buf[sizeof(buf) / sizeof(buf[0]) -1] = '\0';


  ftostr(p.speed,spdString,3);
  ftostr(p.longitude,lngString,9);
  ftostr(p.latitude,latString,9);
  ftostr(p.altitude,altString,2);
  ftostr(p.course,crsString,2);
  ftostr(p.temperature,tmperatureString,2);
  ftostr(p.mainVoltage,mainVoltageString,4);
  ftostr(p.arduinoVoltage,arduVoltageString,4);
  
  
  snprintf(buf,sizeof(buf) - 1,"%lu,%lu,%s,%s,%s,%s,%li,%s,%s,%s,%s#",
        p.numberOfSatellites,
        p.time,
        spdString,
        lngString,
        latString,
        altString,
        p.hdop,
        crsString,
        tmperatureString,
        mainVoltageString,
        arduVoltageString
  );
  //Serial.print(buf);
  Serial1.print(buf);
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

#if defined(CORE_TEENSY) && 0
    usb_midi_write_packed(* (uint32_t*)&message[0] );

    //usb_tx(MIDI_TX_ENDPOINT, tx_packet);
    
    usb_midi_flush_output();
    //while (usbMIDI.read());

#elif 0
    MidiUSB.write(message,sizeof(message));
    MidiUSB.flush();
#endif
  }
  //usbMIDI.send_now();
  //usb_midi_flush_output();
}


