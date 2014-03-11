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
  
  Serial.begin(115200);
  Serial.println("Initialising...");
  A7105_Setup();
  int loopcnt = 0;
  int boundcnt = 0;
  initialize();
  channel = 0x32;
  A7105_WriteReg(A7105_0F_CHANNEL, 0x32);
  Serial.println("Initialisation Complete");
}
  //int loopcnt = 0;
  //int boundcnt = 0;
void loop() {
  
  int startTime, waitTime, hubsanWait, finishTime;
  startTime = micros();
  while (1) {
    if (Serial.available()>4) {
      if (Serial.read()!=23) {
          throttle = rudder = aileron = elevator = 0;
      } else {
      throttle=Serial.read();
      rudder=Serial.read();
      aileron=Serial.read();
      elevator=Serial.read();
      }
    }
    
      //if (state!=0 && state!=1 & state!=128) 
    Serial.print("State: ");
    Serial.println(state);
    //rudder = aileron = elevator = 0x7F; // midpoints?
    //if (boundcnt >= 80 && throttle < 20) throttle += 1;
    //if (loopcnt > 280) throttle = 0; // end test
    //loopcnt += 1;
    //boundcnt = state >= 8 ? boundcnt + 1 : 0;
    //Serial.println("Throttle:");
    //Serial.println(throttle);
    hubsanWait = hubsan_cb();
    finishTime = micros();
    waitTime = hubsanWait - (micros() - startTime);
    //Serial.print("hubsanWait: " ); Serial.println(hubsanWait);
    //Serial.print("waitTime: " ); Serial.println(waitTime);
    //Serial.println(hubsanWait);
    delayMicroseconds(waitTime);
    startTime = micros();
  }
  
  
  
  //Serial.println(A7105_ReadReg(0x00)); 
  //A7105_shoutchannel();
  //A7105_sniffchannel();
  
  //A7105_scanchannels(allowed_ch);
  //eavesdrop();
}

