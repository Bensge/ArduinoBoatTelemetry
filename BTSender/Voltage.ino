#ifndef _VOLTAGE_C_
#define _VOLTAGE_C_

#define arraySize(array) (sizeof(array) / sizeof(array[0]))

#define RegulatorPin A10
#define BatteryPin A6
#define RawPin A2

#define __THROTTLER(n) throttler_##n
#define _THROTTLER(n) __THROTTLER(n)
#define _callEvery(INTERVAL,__COUNT,BLOCK) static unsigned long _THROTTLER(__COUNT) = 0; \
											if (millis() - _THROTTLER(__COUNT) >= INTERVAL){ \
												_THROTTLER(__COUNT) = millis(); \
												BLOCK \
											}
#define callEvery(INTERVAL,BLOCK) _callEvery(INTERVAL,__COUNTER__,BLOCK)


//Function declarations
float batteryVoltage();
float rawVoltage();


//Vars
unsigned char vccValuesPosition = 0;
float vccValues[1/*100*/] = {0};

float batteryValues[20] = {0};
unsigned char batteryValuesPosition = 0;

float rawValues[20] = {0};
unsigned char rawValuesPosition = 0;



//This function is called on ever main loop invocation and needs to throttle by itself
void updateVoltageMeasurements()
{
	callEvery(10,{
		float voltageValue = analogRead(RegulatorPin); //= 1023*3.3V/VCC

		float vccVoltage = 1023.f*3.28f/voltageValue;

		vccValues[vccValuesPosition++] = vccVoltage;

		if (vccValuesPosition == arraySize(vccValues))
		{
			vccValuesPosition = 0;
		}
	});

	callEvery(50,{
		//Battery
		float voltage = batteryVoltage();

		batteryValues[batteryValuesPosition++] = voltage;

		if (batteryValuesPosition == arraySize(batteryValues))
		{
			batteryValuesPosition = 0;
		}

		//Raw
		float rawBatteryVoltage = rawVoltage();

		rawValues[rawValuesPosition++] = rawBatteryVoltage;

		if (rawValuesPosition == arraySize(rawValues))
		{
			rawValuesPosition = 0;
		}
	});
}

float averageVCCVoltage()
{
  //Collect values from circular buffer
	float values[30];

	unsigned char bufferIndex = vccValuesPosition;

	for (unsigned char i = 0; i < arraySize(values); i++)
	{
		values[i] = vccValues[bufferIndex];

		if (bufferIndex == 0)
			bufferIndex = arraySize(vccValues);
		else
			bufferIndex--;
	}

  	//Find smalles value and index
	int smallestValueIndex = 0;
	float smallestValue = 99999;

  	//Find biggest value and index
	int biggestValueIndex = 0;
	float biggestValue = 0;

	for (unsigned char i = 0; i < arraySize(values); i++)
	{
		if (values[i] < smallestValue)
		{
			smallestValue = values[i];
			smallestValueIndex = i;
		}

		if (values[i] > biggestValue)
		{
			biggestValue = values[i];
			biggestValueIndex = i;
		}
	}


  	//Average values, ignoring biggest and smallest value.
	float sum = 0;
	int count = 0;

	for (unsigned char i = 0; i < arraySize(values); i++)
	{
		if (i != smallestValueIndex && i != biggestValueIndex)
		{
			sum += values[i];
			count++;
		}
	}

	return sum / (float)count;
}

float batteryVoltage()
{
  int regulatorVoltageValue = analogRead(RegulatorPin); //= 1023*3.3V/VCC

  float unitsPerVolt = regulatorVoltageValue / 3.274f;

  float v = analogRead(BatteryPin) / unitsPerVolt;

  return v * 4.6; //Incorporate voltage divier with value of 4.6
}

float averageBatteryVoltage()
{
	int circularBufferPosition = batteryValuesPosition;

	float averageValue = 0;
	int num = 0;

	for (unsigned char i = 0; i < arraySize(batteryValues); i++)
	{
		averageValue += batteryValues[circularBufferPosition];
		num++;

		//For next loop enumeration
		if (circularBufferPosition == 0)
			circularBufferPosition = arraySize(batteryValues) - 1;
		else
			circularBufferPosition--;
	}

	averageValue /= (float)num;

	return averageValue;
}

float rawVoltage()
{
  int regulatorVoltageValue = analogRead(RegulatorPin); //= 1023*3.3V/VCC

  float unitsPerVolt = regulatorVoltageValue / 3.274f;

  float v = analogRead(RawPin) / unitsPerVolt;

  return v * 2; //Incorporate voltage divier with value of 2
}

float averageRawVoltage()
{
	int circularBufferPosition = rawValuesPosition;

	float averageValue = 0;
	int num = 0;

	for (unsigned char i = 0; i < arraySize(rawValues); i++)
	{
		averageValue += rawValues[circularBufferPosition];
		num++;

		//For next loop enumeration
		if (circularBufferPosition == 0)
			circularBufferPosition = arraySize(rawValues) - 1;
		else
			circularBufferPosition--;
	}

	averageValue /= (float)num;

	return averageValue;
}

#endif














