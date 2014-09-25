/*
********************************************************
Pin setup :

gio1 chip / arduino miso
BOTH ground chip / ground arduino
vdd chip / 3.3V arduino
sdio chip / one end of a 10-13k resistor
the other end of the resistor / mosi arduino
sck chip / sck arduino
scs chip / pin 10 arduino

If you want to use the additional reset button :

5V to button, button to 10K resistor, resistor to ground, then same pin to pin 2. Add a resistor between pin 12 and RESET pin.

Make sure that output on arduino pins is no more than 3.3V, otherwise the chip would be damaged.
********************************************************
*/


int buttonState = 0;
int resetPin = 12;
int buttonPin = 2;
int i;
void setup() {
  digitalWrite(resetPin, HIGH);
  pinMode(resetPin, OUTPUT);
  pinMode(buttonPin, INPUT);
  verbose = false;
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  RED_OFF();
  GREEN_OFF();
  Serial.begin(115200);
  Serial.flush();
  Serial.println("Initialising...");

  // SPI initialisation and mode configuration
  A7105_Setup();
  delay(2000);  // gives two seconds to open serial monitor to see chip id
  uint8_t chipID[4];
  A7105_ReadChipID(chipID);
  Serial.print("Chip ID: ");
  for (int i = 0; i < 4; ++i) {
    Serial.print(chipID[i]);
    Serial.print("\t");
  }
  Serial.println();
  // calibrate the chip and set the RF frequency, timing, transmission modes, session ID and channel
  initialize();
  
  rudder = aileron = elevator = 0x7F; 
  throttle = 0x00;
  
  Serial.println("Initialisation Complete");
}

void loop() {  

    // start the timer for the first packet transmission
    startTime = micros();
   while (1) {
    if (Serial.available()>4) {
      if (Serial.read()!=23) {
          rudder = aileron = elevator = 0x7F;
      } else {
      throttle=Serial.read();
      rudder=Serial.read();
      aileron=Serial.read();
      elevator=Serial.read();
      }
    }
    
    // print information about which state the RF dialogue is currently in
    //Serial.print("State: ");
    //Serial.println(state);
    
    // perform the correct RF transaction
    hubsanWait = hubsan_cb();
    
    // stop timer for this packet
    finishTime = micros();
    
    // calculate how long to wait before transmitting the next packet
    waitTime = hubsanWait - (micros() - startTime);
    
    // wait that long
    delayMicroseconds(waitTime);
    
    // start the timer again
    startTime = micros();
    
    // reset the card if button is pressed
    buttonState = digitalRead(buttonPin);
    if (buttonState == HIGH) {
      digitalWrite(resetPin, LOW);
      }
     
  }
  
  //Serial.println(A7105_ReadReg(0x00)); 
  //A7105_shoutchannel();
  //A7105_sniffchannel();
  
  //A7105_scanchannels(allowed_ch);
  //eavesdrop();
}

