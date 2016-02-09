//Created 09.12.2015
//Bennos Telemetry Receiver Sketch

#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"
#include "printf.h"
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include "TinyGPS++.h"
#include <BTCommon.h>

#define LCD 0

//Static variables
#if defined(CORE_TEENSY)
RF24 radio(9,10);
#else
RF24 radio(19,18);
#endif
const uint64_t pipes[2] = { 0xF0F0F0F0E1LL, 0xF0F0F0F0D2LL };
#if LCD
LiquidCrystal_I2C lcd(0x27,16,2);
#endif


byte satelliteChar[8] = {
  0b00000,
  0b00001,
  0b11010,
  0b11100,
  0b01110,
  0b10110,
  0b00000,
  0b00000
};

byte clockChar[8] = {
  0x0,
  0xe,
  0x15,
  0x17,
  0x11,
  0xe,
  0x0
};

byte rightArrowChar[8] = {
  0b00000,
  0b00100,
  0b00110,
  0b11111,
  0b00110,
  0b00100,
  0b00000,
  0b00000
};

//Variables
float maxSpeed = 0;

//Functions
void sendUSBPacket(BTPacket p);

#define satelliteCharID 0
#define clockCharID 1
#define rightArrowCharID 2

void setup()
{
  //PC Logging serial
//  Serial.begin(9600);
//  delay(3000);
//  while (!Serial);
//  Serial.println("HI");
//  Serial.print("sizeof(BTPacket) = "); Serial.println(sizeof(BTPacket));
  //printf_begin();
  //nRF24
  radio.begin();
  Serial.println("HI");
  radio.openWritingPipe(pipes[1]);
  radio.openReadingPipe(1,pipes[0]);
Serial.println("HI");
  radio.startListening();
  //radio.printDetails();
  //printf("Done\n");

#if LCD
  lcd.init();
  lcd.createChar(satelliteCharID, satelliteChar);
  lcd.createChar(clockCharID, clockChar);
  lcd.createChar(rightArrowCharID, rightArrowChar);
  lcd.backlight();
  lcd.setCursor(0,0);
  lcd.print("Bennos Telemetry");
#endif
  //Serial.println("Done with setup");
}

BTPacket p;
void loop()
{
    while (radio.available())
    {
      //Serial.println("Got p1");
      radio.read(&p, sizeof(p));
      //Serial.println("Got p");

      uint8_t nos = p.numberOfSatellites;
      float speed = p.speed;

      //Time
      TinyGPSTime t;
      t.setTime(p.time);
      t.commit();

      char timeString[12];
      sprintf(timeString,"%02d:%02d:%02d:%02d",t.hour(),t.minute(),t.second(),t.centisecond());
      Serial.print(timeString);
#if LCD
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.write(clockCharID);
      lcd.print(timeString);

      //NOS
      lcd.setCursor(0,1);
      lcd.write((uint8_t)satelliteCharID);
      lcd.print(String(nos,DEC));

      //Speed
      lcd.setCursor(5,1);
      lcd.write((uint8_t)rightArrowCharID);
      lcd.print(String(speed,2));
      lcd.print("km/h");
#endif
      //p.printDescription();

      if (speed > maxSpeed)
        maxSpeed = speed;

#if LCD
      lcd.setCursor(12,0);
#endif
      
      sendUSBPacket(&p);
    }
}

void sendUSBPacket(BTPacket *p)
{
  uint8_t numberOfBytes = sizeof(BTPacket);
  sendUSB((byte *)p,numberOfBytes);
}

void sendUSB(byte *buffer, unsigned int length)
{
  unsigned int position = 0;
  while (position < length)
  {
    byte message[4] = {0x0B, 'g', 'g', 'g'};

    for (byte i = 0; i < 3; i++)
    {
      message[i + 1] = buffer[position++];

      if (position == length)
        break;
    }

#if defined(CORE_TEENSY)
    //usbMIDI.send_raw();
    usb_midi_write_packed(* (uint32_t*)&message[0] );
    //usbMIDI.send_now();
    usb_midi_flush_output();
    while (usbMIDI.read()) {
      // ignore incoming messages
    }
#else
    MidiUSB.write(message,sizeof(message));
    MidiUSB.flush();
#endif
  }
}


