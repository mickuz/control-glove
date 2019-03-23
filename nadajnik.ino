#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

#define CE_PIN   9
#define CSN_PIN 10
#include<Wire.h>
#define MPU 0x68
#define MPU_2G (0<<4)
#define MPU_4G (1<<4)
#define MPU_8G (2<<4)
#define MPU_16G (3<<4)

float  accelX,   accelY,   accelZ;
float gForceX,  gForceY,  gForceZ;
float  gyroX,    gyroY,    gyroZ;
float rotX,     rotY,     rotZ;
float outRotX,  outRotY,  outRotZ; //Info o obrocie, trzeba dodać sygnał 

bool readingAngle; // Sprawdza czy zmieniamy kąt

int sensorL = A0;    //first flex
int sensorR = A1;    // select the pin for the LED

const byte slaveAddress[5] = {'R','x','A','A','A'};
RF24 radio(CE_PIN, CSN_PIN);
float dataToSend[6];
char txNum = '0';

unsigned long currentMillis;
unsigned long prevMillis;
unsigned long txIntervalMillis = 20;

void setup() 
{
    Serial.begin(230400);
    Wire.begin();
    setupMPU();
    outRotX = 0;
    outRotY= 0;
    outRotZ = 0;
    readingAngle = false;
    radio.begin();
    radio.setDataRate( RF24_250KBPS );
    radio.setRetries(3,5); // delay, count
    radio.openWritingPipe(slaveAddress);
}

void loop() 
{
    if(analogRead(sensorL)<700) { //fleks na A0 uruchamia sterowanie układem odniesienia
      readingAngle = true;
    }else {
      readingAngle = false;
    }
    if(analogRead(sensorR)<700) { //fleks na A0 uruchamia sterowanie układem odniesienia
      outRotX = 0;
      outRotY = 0;
      outRotZ = 0;
    }
    //Serial.println(analogRead(sensorR));
    recordAccelRegisters();
    recordGyroRegisters();
    dataToSend[0] = accelX-603;
    dataToSend[1] = accelY+371;
    dataToSend[2] = accelZ+2267;
    dataToSend[3] = outRotX/2.0;
    dataToSend[4] = outRotY/2.0;
    dataToSend[5] = outRotZ/2.0;
    currentMillis = millis();
    if (currentMillis - prevMillis >= txIntervalMillis) 
    {
        send();
        prevMillis = millis();
    }
}

void setupMPU() 
{
  Wire.beginTransmission(MPU);
  Wire.write(0x6B); 
  Wire.write(0); 
  Wire.endTransmission(true);
  Wire.beginTransmission(MPU);
  Wire.write(0x1B); 
  Wire.write(0x00); 
  Wire.endTransmission(true);
  Wire.beginTransmission(MPU);
  Wire.write(0x1C); 
  Wire.write(0x00); 
  Wire.endTransmission(true);
}

void recordAccelRegisters() 
{
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);
  Wire.endTransmission();
  Wire.requestFrom(MPU,6); //Request Accel Registers (3B - 40)
  while(Wire.available() < 6);
  accelX = Wire.read()<<8|Wire.read(); //Store first two bytes into accelX
  accelY = Wire.read()<<8|Wire.read(); //Store middle two bytes into accelY
  accelZ = Wire.read()<<8|Wire.read(); //Store last two bytes into accelZ
  processAccelData();
}

void processAccelData()
{
  gForceX = accelX / 16384.0;
  gForceY = accelY / 16384.0; 
  gForceZ = accelZ / 16384.0;
}

void recordGyroRegisters() 
{
  Wire.beginTransmission(MPU);
  Wire.write(0x43);
  Wire.endTransmission();
  Wire.requestFrom(MPU,6); //Request Gyro Registers (43 - 48)
  while(Wire.available() < 6);
  gyroX = Wire.read()<<8|Wire.read(); 
  gyroY = Wire.read()<<8|Wire.read(); 
  gyroZ = Wire.read()<<8|Wire.read(); 
  processGyroData();
}

void processGyroData() 
{
  rotX = gyroX / 131.0;
  rotY = gyroY / 131.0; 
  rotZ = gyroZ / 131.0;
  rotX *= 0.0174532925;
  rotY *= 0.0174532925;
  rotZ *= 0.0174532925;
  if(readingAngle){
    outRotX += rotX;
    outRotY += rotY;
    outRotZ += rotZ;
    if(outRotX >= 6.28318530718)
      outRotX-=2*6.28318530718;
    if(outRotY >= 6.28318530718)
      outRotY-=2*6.28318530718;
    if(outRotZ >= 6.28318530718)
      outRotZ-=2*6.28318530718;
    if(outRotX <= -6.28318530718)
      outRotX+=2*6.28318530718;
    if(outRotY <= -6.28318530718)
      outRotY+=2*6.28318530718;
    if(outRotZ <= -6.28318530718)
      outRotZ+=2*6.28318530718;
  }
}

void send() 
{
    bool rslt;
    rslt = radio.write( &dataToSend, sizeof(dataToSend) );
    for(int i = 0; i < 6; i++)
    {
      Serial.println(dataToSend[i]);
    }
//    Serial.println();
//    if (!rslt) 
//      Serial.println("Tx failed");
}
