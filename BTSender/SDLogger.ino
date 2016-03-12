/*
#ifndef _SDLOGGER_C_
#define _SDLOGGER_C_

#include <SD.h>

#define DEBUG false
//#define Serial if(DEBUG)Serial 
#define SDPort 9

File logFile;

void sdloggerInit()
{
	if (!SD.begin(SDPort))
	{
		Serial.println("Err open SD");
	}

	int logFileNumber = 0;
	String fileName;
	do {
		logFileNumber++;
		fileName = String("gpslog_") + String(logFileNumber) + String(".csv");
	} while (SD.exists(fileName));

	logFile = SD.open(fileName,FILE_WRITE);

	if (!logFile)
	{
		Serial.print("Err open file");
	}
	else {
		//logFile.println("numberOfSatellites;time;speed;longitude;latitude;altitude;hdop;course");
	logFile.println("nos;t;s;lng;lat;alt;hdop;crs");
	}
}

void logPacket(BTPacket p)
{
	if (logFile)
	{
		char lineBuffer[256];

		snprintf(lineBuffer,sizeof(lineBuffer),"%u,%u,%f,%f,%f,%f,%i,%f",
			p.numberOfSatellites,
			p.time,
			p.speed,
			p.longitude,
			p.latitude,
			p.altitude,
			p.hdop,
			p.course
		);

		logFile.println(lineBuffer);
	logFile.flush();
	}
}

#endif
*/