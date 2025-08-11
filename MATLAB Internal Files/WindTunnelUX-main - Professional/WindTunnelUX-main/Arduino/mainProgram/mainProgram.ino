#include <Wire.h>
#include <stdint.h>
#include <math.h>
#include <ams5915.h>
#include <Adafruit_LPS35HW.h>
#define varName(var) #var // Allows printing of variable names

// AMS5915 Device Addresses:
const uint8_t ADDR_P1 = 0x1F;
const uint8_t ADDR_P3 = 0x12;
const uint8_t ADDR_P4 = 0x11;

const float CALIBRATION_MULT_P1 = 0.7683;
const float CALIBRATION_MULT_P3 = 1.9135;
const float CALIBRATION_MULT_P4 = 1.9207;
float CALIBRATION_OFST_P1 = -8.6780;
float CALIBRATION_OFST_P3 = 0;
float CALIBRATION_OFST_P4 = 0;

// Absolute pressure sensor address:
const uint8_t ADDR_ABS = 0x5D;	

// Initialize abs pressure sensor
Adafruit_LPS35HW absSensor = Adafruit_LPS35HW();

// Using the AMS5915 library by Brian Taylor (Bolder Flight Systems)
bfs::Ams5915 p1(&Wire, ADDR_P1, bfs::Ams5915::AMS5915_0020_D_B, 18);
bfs::Ams5915 p3(&Wire, ADDR_P3, bfs::Ams5915::AMS5915_0020_D, 33);
bfs::Ams5915 p4(&Wire, ADDR_P4, bfs::Ams5915::AMS5915_0020_D, 85);

// Values needed for fan setting
const int PWM_PIN = 6; // Pin for the fan's PWM signal
int pwr           = 0; // Determines the command sent to the fan as a percentage of max power (10-100%)
int write_val     = 0; // The value that will be sent over analogWrite()

// Density. Kind of a placeholder.
float rho = 1.14;


void setup() {
	pinMode(PWM_PIN, OUTPUT);  // Set the fan pin to be an output
	Serial.begin(9600);        // start serial at 9600 baud for monitoring pwr setting
	while (!Serial){}          // Wait until the serial port is ready
	// Initalize wire library for I2C communication
	Wire.begin();
	Wire.setClock(100000);     // A wire frequency of 400 kHz (fast mode) is the max supported by AMS 5915
	// Print error messages if communication can't be established
	if (!p1.Begin()) {
		Serial.println("Error communicating with p1");
		while(1){};
	}
	if (!p3.Begin()) {
		Serial.println("Error communicating with p3");
		while(1){};
	}
	if (!p4.Begin()) {
		Serial.println("Error communicating with p4");
		while (1) {};
	}
	if (!absSensor.begin_I2C()) {
		Serial.println("Error communicating with absolute pressure sensor");
	}
	
	// Set the abs pressure sensor to one shot mode
	absSensor.setDataRate(LPS35HW_RATE_ONE_SHOT);
	getDensity();
  //Serial.println(rho);

	CALIBRATION_OFST_P1 = p1.pres_pa();
	CALIBRATION_OFST_P3 = p3.pres_pa();
	CALIBRATION_OFST_P4 = p4.pres_pa();
}

void CollectAMSData(bfs::Ams5915 sensor, int purpose, int name) {
	uint16_t pres_cnts = sensor.pres_cnts();
	float pres_mbar;
	float extra_val = 0.0;
	float press;
	float temp;
	if (sensor.Read()) {
		press     = sensor.pres_pa();
		temp      = sensor.die_temp_c();
		pres_mbar = sensor.pres_mbar();
	}
  float pressCorrected = pressureCorrection(press, name);
	// Determine what the sensor is used for (i.e. speed or aoa). This will
	// determine what is printed in the "extra_val" column of the serial line
	if (name == 3 || name == 4) {
		extra_val = calcAirspeed(pressCorrected);
	}

	// Print to serial with tabs separating pressure and temp and a return
	Serial.print(String(name));
	// Serial.print("\t");
	// Serial.print(pres_cnts);
	//Serial.print("\t");
	//Serial.print(pres_mbar);
	Serial.print("\t");
	Serial.print(pressCorrected);
	Serial.print("\t");
	//Serial.print(temp);
	//Serial.print("\t");
	Serial.println(extra_val);
}

float calcAirspeed(float dp) {
	if (dp < 0) {
		dp = 0.0f;
	}
	float spd = sqrt(2.0f*dp/rho);
	return spd;
}

void loop() {

	// The value to write to analogWrite is between 0 and 255. 0 is 0% duty cycle. 255 is 100% duty cycle
	write_val = pwr*255/100;

	// Output the initial power setting to the fan
	analogWrite(6, write_val);

	// Check if the user has input a change to the power setting.
	if(Serial.available()) {
		// Set pwr to be the user's new desired value
		pwr = Serial.parseInt();   // parse the power setting from serial
		while (Serial.available() != 0 ) {
			Serial.read();
		}
	}

	CollectAMSData(p1, 2, 1);
	CollectAMSData(p3, 1, 3);
	CollectAMSData(p4, 1, 4);
}

float getDensity() {
	float temperature;
	float pressure;
	absSensor.takeMeasurement();
	temperature = absSensor.readTemperature() + 273.15f; // Kelvin
	pressure = absSensor.readPressure() * 100; // Pa
	rho = pressure / (287.0f * temperature);
  //Serial.println(pressure);
  //Serial.println(temperature);
}

float pressureCorrection(float pressure, int name) {
	// Note that pressure must be in units of Pa
	float correctedPressure;
	float multiple;
	float offset;
	switch (name) {
		case 1: {
			multiple = CALIBRATION_MULT_P1;
			offset = CALIBRATION_OFST_P1;
			break;
		}
		case 3: {
			multiple = CALIBRATION_MULT_P3;
			offset = CALIBRATION_OFST_P3;
			break;
		}
		case 4: {
			multiple = CALIBRATION_MULT_P4;
			offset = CALIBRATION_OFST_P4;
			break;
		}
		default: {
			multiple = 1;
			offset = 0;
		}
	}
	correctedPressure = (pressure)*multiple - offset;
	return correctedPressure;
}
