#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>
#include <stdlib.h>
#include <stdio.h>
#include <ArduinoJson.h>


// Definimos una dirección MAC cualquiera
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};

// Definimos la dirección IP de nuestro Arduino (depende de la red local)
IPAddress ip(172, 25, 26, 36);

// Definir el DNS y el gateway
IPAddress dns(172, 25, 24, 1);
IPAddress gateway(172, 25, 24, 1);

// Definimos la IP y el puerto del servidor al que conectarnos (del CiTIUS)
IPAddress server(172, 16, 242, 197); int puerto = 2305;

// Initialize the Ethernet client library
EthernetClient client;

// Servidor NTP para consultar el tiempo (de la USC)
IPAddress timeServer(193, 144, 75, 12);

// Central European Time
const int timeZone = 1;

// local port to listen for UDP packets
EthernetUDP Udp; unsigned int localPort = 8888;

void setup() {
  // initialize serial communication at 9600 bits per second
  Serial.begin(9600);

   // wait for serial port to connect
  while (!Serial);

  Serial.println("-----------------------------");
  Serial.println("Empezando el setup");  

  // start the Ethernet connection:
  Ethernet.begin(mac, ip, dns, gateway);

  // Check for Ethernet hardware present
  if (Ethernet.hardwareStatus() == EthernetNoHardware) {
    Serial.println("Ethernet shield was not found.  Sorry, can't run without hardware. :(");
    while (true) {
      delay(1);
    }
  }
  while (Ethernet.linkStatus() == LinkOFF) {
    Serial.println("Ethernet cable is not connected.");
    delay(500);
  }

  delay(1000);

  Serial.println("connecting to the USC server");

  // if you get a connection, report back via serial:
  if (client.connect(server, puerto)) {
    Serial.println("connected");
  } else {
    Serial.println("connection failed");
  }

  Udp.begin(localPort);
  Serial.println("waiting for sync with the NTP server");
  setSyncProvider(getNtpTime);

  Serial.println("Finalizando el setup");
  Serial.println("-----------------------------");
  Serial.println("");  
}

// the loop routine runs over and over again forever:
void loop() {
  
  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
  }
  
  // 1000 = 1s
  delay(2000);
  
  // read the input on analog pin 1:
  int sensorValue1 = analogRead(A1);

  // read the input on analog pin 2:
  int sensorValue2 = analogRead(A2);

    // read the input on analog pin 2:
  int sensorValue3 = analogRead(A3);
  
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float voltage1 = sensorValue1 * (5.0 / 1023.0);
  float voltage2 = sensorValue2 * (5.0 / 1023.0);
  float voltage3 = sensorValue3;

  // Calcular la temperatura
  float temperature = (voltage1 - 0.5) / 0.01;
  
  // Sacamos el ROn a partir del voltage
  float ROn = (50000 - (voltage2*10000)) / voltage2;
  // Sacamos la luz a partir del ROn 
  float lux = pow(((log10(ROn) - log10(29000)) / (-0.9)) + log10(10), 10);
  
  //Infrarrojo
  bool flame = voltage3 > 100; 

  // Imprimir de la medición de los sensores
  Serial.println("-----------------------------");
  
  // Imprimir los valores leidos
  Serial.print("Voltage A1: ");
  Serial.println(voltage1);
  Serial.print("Temp : ");
  Serial.println(temperature);
  Serial.println();
  Serial.print("Voltage A2: ");
  Serial.println(voltage2);
  Serial.print("ROn : ");
  Serial.println(ROn);
  Serial.print("Lux : ");
  Serial.println(lux);
  Serial.println();
  Serial.print("Valor Infrarrojo: ");
  Serial.println(voltage3);
  Serial.print("Incendio: ");
  Serial.println(flame);
  Serial.println();

  char temperature_string[8];
  dtostrf(temperature, 4, 2, temperature_string);

  char lighting_string[8];
  dtostrf(lux, 4, 2, lighting_string);
  
  char json[300];
  sprintf(json, "{\"timeInstant\":{\"value\":\"%d-%d-%dT%d:%d:%dZ\",\"type\":\"time\"},\"temperature\":{\"value\":%s,\"type\":\"float\"},\"lighting\":{\"value\":%s,\"type\":\"float\"},\"flame\":{\"value\":%d,\"type\":\"boolean\"}}", year(), month(), day(), hour(), minute(), second(), temperature_string, lighting_string, flame);

  // Enviamos los datos con PostPage
  Serial.println("Enviamos los datos");
  postPage("172.16.242.197", "/v2/entities/Mote1/attrs/", json);
  
  Serial.println("-----------------------------");
}

/*-------- PostPage code ----------*/

void postPage(char* domainBuffer, char* page, char* thisData){
  int inChar;
  char outBuf[64];

  // send the header
  sprintf(outBuf, "POST %s HTTP/1.1", page);
  client.println(outBuf);
  sprintf(outBuf,"Host: %s", domainBuffer);
  client.println(outBuf);
  client.println(F("Accept: application/json"));
  client.println(F("Content-Type: application/json"));
  sprintf(outBuf,"Content-Length: %u\r\n", strlen(thisData));  
  client.println(outBuf);

  // send the body (variables)
  client.print(thisData);
}

/*-------- NTP code ----------*/

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime(){
  while (Udp.parsePacket() > 0);
  Serial.println("Transmit NTP Request");
  sendNTPpacket(timeServer);
  uint32_t beginWait = millis();
  
  while (millis() - beginWait < 1000) {
    int size = Udp.parsePacket();
    
    if (size >= NTP_PACKET_SIZE) {
      Serial.println("Receive NTP Response");
      Udp.read(packetBuffer, NTP_PACKET_SIZE);
      unsigned long secsSince1900;
      
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  Serial.println("No NTP Response");
  return 0;
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address){
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  
  // Initialize values needed to form NTP request
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;
  
  // all NTP fields have been given values, now you can send a packet requesting a timestamp:                 
  Udp.beginPacket(address, 123); //NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}
