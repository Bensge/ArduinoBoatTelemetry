//Created 09.12.2015
//Bennos Telemetry Sender Sketch

#include <SPI.h>
#include "TinyGPS++.h"
#include "RF24.h"
#include <BTCommon.h>
#include <DallasTemperature.h>

//Macros
#define SDLogger 0


#define GPSSerial Serial1
#define DEBUG true
//#define Serial if(DEBUG)Serial 
#define temperaturePin 8


#define __THROTTLER(n) throttler_##n
#define _THROTTLER(n) __THROTTLER(n)
#define _callEvery(INTERVAL,__COUNT,BLOCK) static unsigned long _THROTTLER(__COUNT) = 0; \
											if (millis() - _THROTTLER(__COUNT) >= INTERVAL){ \
												_THROTTLER(__COUNT) = millis(); \
												BLOCK \
											}

#define callEvery(INTERVAL,BLOCK) _callEvery(INTERVAL,__COUNTER__,BLOCK)


//Static variables

//GPS
TinyGPSPlus gps;
BTPacket p = {0};

//SD

//Temperature
OneWire temperatureBUS(temperaturePin);
DallasTemperature dallasSensors(&temperatureBUS);
DeviceAddress firstThermometer;


//RF24
RF24 radio(19, 18);
const uint64_t pipes[2] = { 0xF0F0F0F0E1LL, 0xF0F0F0F0D2LL };


void gpsSetup();

float averageBatteryVoltage();

void setup()
{
	//PC Logging serial
	Serial.begin(115200);
	//while(!Serial);
	//GPS serial
	gpsSetup();
	GPSSerial.begin(115200);

	//Temperature
	dallasSensors.begin();
	Serial.print("Found ");
  Serial.print(dallasSensors.getDeviceCount(), DEC);
  	Serial.println(" dallas sensors.");
  	Serial.print("Parasite power is: "); 
  	if (dallasSensors.isParasitePowerMode()) Serial.println("ON");
  	else Serial.println("OFF");

  	if (!dallasSensors.getAddress(firstThermometer, 0))
  		Serial.println("Unable to find address for thermometer 0");
  	dallasSensors.setResolution(firstThermometer, 8);
  

#if SDLogger
	//SD
	sdloggerInit();
#endif

	//nRF24
	radio.begin();
	radio.openWritingPipe(pipes[0]);
	radio.openReadingPipe(1,pipes[1]);
}



void loop()
{
	//Voltage
	updateVoltageMeasurements();
	//GPS
	while (GPSSerial.available() > 0)
	{
		gps << GPSSerial.read();
	//Serial.print(GPSSerial.read());
	}

	//Check for updated GPS data
	if (gps.time.isUpdated())
	{
		// callEvery(1000,
		// {
			p.numberOfSatellites = gps.satellites.value();
			p.time = gps.time.value();
			p.speed = gps.speed.kmph();
			p.longitude = gps.location.lng();
			p.latitude = gps.location.lat();
			p.altitude = gps.altitude.meters();
			p.hdop = gps.hdop.value();
			p.course = gps.course.deg();

			p.mainVoltage = averageBatteryVoltage();
			p.arduinoVoltage = averageRawVoltage();

			p.printDescription();

		// });
	}

	callEvery(1000,{
		p.temperature = dallasSensors.getTempC(firstThermometer);
    	dallasSensors.requestTemperatures();
	});

	callEvery(300,{
		//nRF24
		radio.write( &p, sizeof(p));
		Serial.println("Sent!");
	});

	// callEvery(1000,{
	// 	Serial.print("Battery voltage: ");
	// 	Serial.println(averageBatteryVoltage());

	// 	Serial.print("Raw voltage: ");
	// 	Serial.println(averageRawVoltage());
	// });
}

void gpsSendCommand(const byte *cmd, int length, int delayTime)
{
	GPSSerial.write(cmd,length);

	delay(delayTime);

	while (GPSSerial.available()) GPSSerial.read();
}

#define gpsCommand(cmd,delay) gpsSendCommand(cmd,sizeof(cmd),delay)

void gpsSetup()
{
  //Set baudrate to 115200
	delay(1000);
	GPSSerial.begin(9600);

	const byte setBaudrateCommand[] = { 
		0xB5, 0x62, 0x06, 0x00,
		0x14, 0x00, 0x01, 0x00, 
		0x00, 0x00, 0xD0, 0x08, 
		0x00, 0x00, 0x00, 0xC2, 
		0x01, 0x00, 0x07, 0x00, 
		0x03, 0x00, 0x00, 0x00, 
		0x00, 0x00, 0xC0, 0x7E
	};

	const byte confirmBaudrateCommand[] = {
		0xB5, 0x62, 0x06, 0x00,
		0x01, 0x00, 0x01, 0x08,
		0x22
	};

	gpsCommand(setBaudrateCommand,100);

	gpsCommand(confirmBaudrateCommand,200);

	GPSSerial.end();

	delay(1500);

	//Set measurement period to 300ms

	GPSSerial.begin(115200);

	const byte setRateCommand[] = {
		0xB5, 0x62, 0x06, 0x08,
		0x06, 0x00, 0x2C, 0x01,
		0x01, 0x00, 0x01, 0x00,
		0x43, 0xC7, 0xB5, 0x62,
		0x06, 0x08, 0x00, 0x00,
		0x0E, 0x30
	};

	gpsCommand(setRateCommand,200);

	const byte disableSatellitesCommand[] = {
		0xB5, 0x62, 0x06, 0x01,
		0x03, 0x00, 0xF0, 0x03,
		0x00, 0xFD, 0x15
	};

//  const byte disableActiveSatellitesCommand[] = {
//                                          0xB5, 0x62, 0x06, 0x01, 
//                                          0x03, 0x00, 0xF0, 0x02, 
//                                          0x00, 0xFC, 0x13
//                                          };

	const byte disablePlainLatLngCommand[] = {
		0xB5, 0x62, 0x06, 0x01, 
		0x03, 0x00, 0xF0, 0x01, 
		0x00, 0xFB, 0x11
	};

  	//Set to 2D Fix only, 0.3m/s static hold threshold, dynamic model "Sea":
	/*const byte setNavigationSettings[] = {
		0xB5, 0x62, 0x06, 0x24,
		0x24, 0x00, 0xFF, 0xFF,
		0x05, 0x01, 0x00, 0x00,
		0x00, 0x00, 0x10, 0x27,
		0x00, 0x00, 0x05, 0x00,
		0xFA, 0x00, 0xFA, 0x00,
		0x64, 0x00, 0x2C, 0x01,
		0x1E, 0x3C, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x6D, 0x28,
		0xB5, 0x62, 0x06, 0x24,
		0x00, 0x00, 0x2A, 0x84
	}; */
	gpsCommand(disableSatellitesCommand,200);

	gpsCommand(disablePlainLatLngCommand,200);

	GPSSerial.end();
}
