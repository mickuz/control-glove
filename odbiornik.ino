#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <Wire.h>

#define CE_PIN 9
#define CSN_PIN 10

const byte thisSlaveAddress[5] = {'R','x','A','A','A'};
RF24 radio(CE_PIN, CSN_PIN);
float dataReceived[6];

void setup() 
{
    Serial.begin(230400);
    radio.begin();
    radio.setDataRate( RF24_250KBPS );
    radio.openReadingPipe(1, thisSlaveAddress);
    radio.startListening();
}

void loop() 
{
    getData();
    printData();
    delay(20);
}

void getData() 
{
    if ( radio.available() ) 
    {
        radio.read( &dataReceived, sizeof(dataReceived) );
    }
}

void printData() 
{
  for(int i = 0; i < 6; i++)
  {
    Serial.println(dataReceived[i]);
  }
}
