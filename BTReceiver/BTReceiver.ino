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

//Static variables
RF24 radio(7,8);
const uint64_t pipes[2] = { 0xF0F0F0F0E1LL, 0xF0F0F0F0D2LL };
LiquidCrystal_I2C lcd(0x27,16,2);

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
  //Serial.begin(9600);

  //USB Packet sending
  Keyboard.begin();

  //nRF24
  radio.begin();
  radio.openWritingPipe(pipes[1]);
  radio.openReadingPipe(1,pipes[0]);

  radio.startListening();

  lcd.init();
  lcd.createChar(satelliteCharID, satelliteChar);
  lcd.createChar(clockCharID, clockChar);
  lcd.createChar(rightArrowCharID, rightArrowChar);
  lcd.backlight();
  lcd.setCursor(0,0);
  lcd.print("Bennos Telemetry");
}

void loop()
{
  if (radio.available())
  {
    BTPacket p;
    while (radio.available())
    {
      radio.read(&p, sizeof(p));

      uint8_t nos = p.numberOfSatellites;
      float speed = p.speed;

      //Time
      TinyGPSTime t;
      t.setTime(p.time);
      t.commit();

      char timeString[12];
      sprintf(timeString,"%02d:%02d:%02d:%02d",t.hour(),t.minute(),t.second(),t.centisecond());

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
      p.printDescription();

      if (speed > maxSpeed)
        maxSpeed = speed;

      lcd.setCursor(12,0);
      
      sendUSBPacket(p);
    }
  }
}

void sendUSBPacket(BTPacket p)
{
  uint8_t numberOfBytes = sizeof(BTPacket);
  for (uint8_t i = 0; i < numberOfBytes * 2; i++)
  {
    
    byte data = *(((byte *)&p) + i/2);

    if (i % 2 != 0)
    {
      Keyboard.print(hexDigitFromNibble(data & 0xF));
    }
    else {
      Keyboard.print(hexDigitFromNibble(data >> 4));
    }
    delay(5);
  }
  Keyboard.print(btPacketDelimiter);
}

char hexDigitFromNibble(uint8_t number)
{
  switch (number)
  { 
    case 0:
      return '0';
    case 0x1:
      return '1';
    case 0x2:
      return '2';
    case 0x3:
      return '3';
    case 0x4:
      return '4';
    case 0x5:
      return '5';
    case 0x6:
      return '6';
    case 0x7:
      return '7';
    case 0x8:
      return '8';
    case 0x9:
      return '9';
    case 0xA:
      return 'A';
    case 0xB:
      return 'B';
    case 0xC:
      return 'C';
    case 0xD:
      return 'D';
    case 0xE:
      return 'E';
    case 0xF:
      return 'F';
    default:
      return '0';
  }
}


