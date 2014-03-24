/*
********************************************************
Pin setup :

gio1 chip / arduino miso
BOTH ground chip / ground arduino
vdd chip / 3.3V arduino
sdio chip / one end of a 10k resistor
the other end of the resistor / mosi arduino
sck chip / sck arduino
scs chip / pin 10 arduino


Make sure thet output on arduino pins is no more than 3.3V, otherwise the chip would be damaged.
********************************************************
*/
void setup() {
  verbose = false;
  pinMode(RED_LED, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);
  RED_OFF();
  BLUE_OFF();
  Serial.begin(115200);
  Serial.flush();
  Serial.println("Initialising...");

  // SPI initialisation and mode configuration
  A7105_Setup();
  
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
    
    // print information about which state the RF dialogue os currently in
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
  }
  
  //Serial.println(A7105_ReadReg(0x00)); 
  //A7105_shoutchannel();
  //A7105_sniffchannel();
  
  //A7105_scanchannels(allowed_ch);
  //eavesdrop();
}

