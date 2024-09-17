#include <math.h>
#include <ntp-time.h>
#include <HttpClient.h>

// Constantes del codigo
const int serial = 9600;
const int SenhalDigital = 4095; // Numero entero asignado al valor 3.3V recibido
const float VIn = 3.3; // 3.3 V

// Constantes del servidor NTP
static char timeServer[] = "hora.usc.es";
NtpTime ntptime=NtpTime(10,timeServer); 

// Constantes del server
IPAddress server(172, 16, 240, 210);
int port = 2303;
const String path = "/v2/entities/Mote2/attrs";

// Constantes sensor temperatura
const float V0C = 0.5; // 500 mV
const float Tc = 0.01; // 10 mV/ºC

// Constantes sensor lux
const float Gamma = 0.9; // 10 mV/ºC
const int BaseLux = 10; // 10k omh
const int Rf = 10000; // 10k omh
const int R10 = 29000; // 29k omh en 10 lux

// Constantes sensor infrarrojos
const int UmbralUV = 30; // 29k omh en 10 lux

void setup() {
    ntptime.start();
    Time.setTime(ntptime.now());
    
    Serial.begin(serial);
    while (!Serial);

    Serial.println("Hello Serial!");
}

void loop() {
    int sensorValue1 = analogRead(A0);  // Valor del pin A0, comprendido entre 0 y 4095
    float VOut1 = sensorValue1  * (VIn / SenhalDigital); // Normalizamos el valor a voltios
    
    Serial.print("Salida A0 sin normalizar: ");
    Serial.println(sensorValue1); 
    
    Serial.print("Salida A0 normalizada: ");
    Serial.print(VOut1); 
    Serial.println(" V");


    String temperature = String(( VOut1 - V0C) / Tc); // Resta los voltios tipicos del sensor y divide por el Coeficiente de Temperatura Tc

    Serial.print("Temperatura: ");
    Serial.println(temperature); 

    // Publica el evento. El nombre del evento es "sensor_value" y el dato es el valor leído
    Particle.publish("temperature_value", temperature, PRIVATE);
    
    
    // -----------------------------Fotosensor--------------------
    int sensorValue2 = analogRead(A1);  // Valor del pin A1
    float VOut2 = sensorValue2  * (VIn / SenhalDigital); // Normalizamos el valor a voltios
    
    Serial.print("Salida A1 sin normalizar: ");
    Serial.println(sensorValue2); 
    
    // Sacamos el ROn a partir del voltage
    float ROn = (( VIn * Rf / VOut2) - Rf); //
    
    Serial.print("Salida A1 normalizada: ");
    Serial.print(ROn); 
    Serial.println(" ohm");


    // Sacamos la luz a partir del ROn 
    // Funcion a despejar -> gamma = ( log(R10) - log(ROn) ) / ( log(lux) - log(BaseLux) )
    float lux = pow(10, (log10(R10) - log10(ROn)) / Gamma + 1 );

    Serial.print("Luz: ");
    Serial.print(lux);
    Serial.println(" lux");
    
    String luxS = String(lux);

    // Publica el evento. El nombre del evento es "sensor_value" y el dato es el valor leído
    Particle.publish("luz_value", luxS, PRIVATE);
    
    
    // -----------------------------Infrarrojos--------------------
    int sensorValue3 = analogRead(A2);  // Valor del pin A2
    bool isUV = false;
    
    Serial.print("Salida A2 sin normalizar: ");
    Serial.println(sensorValue3); 
    
    Serial.print("Se detectan infrarrojos?: ");
    if (sensorValue3 > UmbralUV) {
        Serial.println("Si :)"); 
        isUV = true;
    } else {
        Serial.println("No :("); 
    }
    
    String isUVS = String(isUV);
    // Publica el evento. El nombre del evento es "is_UV" y el dato es el string false
    Particle.publish("is_UV", isUVS, PRIVATE);

    
    String isUVS_json = isUV ? "true" : "false";
    
    Serial.print("Time.year(): ");
    Serial.println(Time.year());

    // Obtener la hora actual en formato ISO8601
    String isoTime = String(Time.year()) + "-" + 
                    ((Time.month()<10)?"0":"") + String(Time.month()) + "-" + 
                    ((Time.day()<10)?"0":"") + String(Time.day()) + "T" + 
                    ((Time.hour()<10)?"0":"") + String(Time.hour()) + ":" + 
                    ((Time.minute()<10)?"0":"") + String(Time.minute()) + ":" + 
                    ((Time.second()<10)?"0":"") + String(Time.second()) + "Z";

    String jsonData = "{\"timeInstant\": {\"value\": \"" + isoTime + 
                    "\", \"type\": \"time\", \"metadata\": {\"timeInstantUnit\": {\"value\": \"ISO8601\", \"type\": \"string\"}}}, \"temperature\": {\"value\": " + 
                    temperature + ", \"type\": \"float\", \"metadata\": {\"temperatureUnit\": {\"value\": \"celsius\", \"type\": \"string\"}}}, \"light\": {\"value\": " + 
                    luxS + ", \"type\": \"float\", \"metadata\": {\"temperatureUnit\": {\"value\": \"lux\", \"type\": \"string\"}}}, \"UV\": {\"value\": " + 
                    isUVS_json + ", \"type\": \"boolean\", \"metadata\": {\"temperatureUnit\": {\"value\": \"detects UV\", \"type\": \"string\"}}}}";

    Serial.println(jsonData);

    HttpClient http;
    http_header_t headers[] = {
        { "Content-Type", "application/json" },
        { NULL, NULL } // NOTE: Always terminate headers will NULL
    };
    http_request_t request;
    http_response_t response;

    request.hostname = server.toString();
    request.port = port;
    request.path = path;
    request.body = jsonData;

    http.post(request, response, headers);

    Serial.print("Response status: ");
    Serial.println(response.status);

    Serial.print("Response body: ");
    Serial.println(response.body);

    Serial.println(".");
    Serial.println("."); 
    
    delay(5000);  // Espera 5000 milisegundos (5 segundos) entre publicaciones
}