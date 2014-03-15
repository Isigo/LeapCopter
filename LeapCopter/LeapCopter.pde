/**
*Author : Théo Baron, with the great help of Raphaël Duchon-Doris
*Creation date : 17/12/2013
*Last update : 14/03/2014
*************************************************

LeapCopter is a LeapMotion application made for controlling a quadcopter Hubsan X4 with the LeapMotion controller.
Contact : theo.lucaroni@gmail.com

*************************************************
**/

import de.voidplus.leapmotion.*;
import processing.serial.*;

CopterModel copter;
CopterVisualisation visual;
int etat = 2;
int mode = 1;
int precisionMultiplicator = 50;
int stabilisation = 1;
int rudder_enabled = 0;
long timeToWait = 10;
long lastTime;
int throttle_lock = 0;
float stabilisation_throttle = 0.65;

LeapMotion leap;

void setup()
{
  size(800, 640, P3D);
  background(255);
  lights();
  fill(50);
  //noFill();
  ellipseMode(CENTER);
  noStroke();
  frameRate(30);
  PFont font = createFont("SansSerif", 20);    
  textFont(font);
  textAlign(LEFT);
  copter = new CopterModel((PApplet)this);
  visual = new CopterVisualisation(copter, 0, 490, 100);
  lastTime = millis();
  leap = new LeapMotion(this).withGestures("key_tap, circle"); // leap detects key_tap and circle gestures, for a further use ( flips for circle gesture ? stabilisation or control on/off for key_tap gesture ?)
}
boolean newframe=false;
void draw()
{
  background(255);
  int fps = leap.getFrameRate();
  visual.update();
  copter.sendData();
  float stepSize = 0.01;  
  int finger_detected = 0;
  for(Hand hand : leap.getHands())
  {
     hand.draw();
    int     hand_id          = hand.getId();
    PVector hand_position    = hand.getPosition();
    PVector hand_stabilized  = hand.getStabilizedPosition();
    PVector hand_direction   = hand.getDirection();
    PVector hand_dynamics    = hand.getDynamics();
    float   hand_roll        = hand.getRoll();
    float   hand_pitch       = hand.getPitch();
    float   hand_yaw         = hand.getYaw();
    float   hand_time        = hand.getTimeVisible();
    PVector sphere_position  = hand.getSpherePosition();
    float   sphere_radius    = hand.getSphereRadius();
     //copter.rudder=hand_yaw/50;
    text("Hand Position :", 660, 490);
    text(hand_position.x, 660, 530);
    text(hand_position.y, 660, 560);
    text(hand_position.z, 660, 590);
    /*handX = hand_position.x/10;
    handY = hand_position.y/10;*/
     
     for(Finger finger : hand.getFingers()){
     finger.draw();
      int     finger_id         = finger.getId();
      PVector finger_position   = finger.getPosition();
      PVector finger_stabilized = finger.getStabilizedPosition();
      PVector finger_velocity   = finger.getVelocity();
      PVector finger_direction  = finger.getDirection();
      float   finger_time       = finger.getTimeVisible();
      int     touch_zone        = finger.getTouchZone();
      float   touch_distance    = finger.getTouchDistance();
      
      finger_detected = 1;
      switch(touch_zone) //touch zone declaration
      {
        case -1:
        break;
        
        case 0:
        hand.draw();
        break;
        
        case 1:
        break;
        
      }
     } //end of for:fingers
      if(etat == 1)//if control on
      {
        if(mode == 1)//if leap mode
        {
          if(finger_detected == 1)// if hand opened
          {
            if (throttle_lock == 0)
            {
          copter.throttle=(hand_position.y/-200)+2.90; //Changed for less sensitive control
            }
          copter.elevator=(hand_roll/(-1*precisionMultiplicator))+0.15;
          copter.aileron=hand_pitch/(1*precisionMultiplicator);
          if(rudder_enabled == 1)
            {
              copter.rudder=(hand_yaw/90)-0.15;
            }
            else
            {
              copter.rudder = 0;
            }
          }
      if(finger_detected == 0) //self landing code part if you close your hand
      {
      if(stabilisation == 0)/// if stabilisation == 0 you have no control
      {
        copter.elevator = copter.aileron = 0;
        //self landing
      if(copter.throttle > 0)
      {
        copter.throttle -= stepSize;
        if (millis() - lastTime > timeToWait)
          {
            copter.throttle -= stepSize;
            lastTime = millis();
          }
      }
      }//end of if(stabilisation)
      }//end of if hand opened
      }//end of if leap mode
      }//end of if control on
    
  } //end of for:hand
      
      if(etat == 1) //if control on
      {
        if(mode == 1) //leap control
        {
          
          if (stabilisation == 1) //stabilisation code part
          {
            copter.throttle=stabilisation_throttle;
            copter.elevator=0;
            copter.aileron=0;
            copter.rudder = 0;

           
          }
          
         
        }
        if (mode == 2) //keyboard control
        {
          if (stabilisation == 1)//if stabilisation on
          {
            copter.throttle = stabilisation_throttle;
            copter.elevator = 0;
            copter.aileron = 0;
            copter.rudder = 0;
          }
        }
          
      }
      
     //maximum values
     if(copter.throttle > 2)
     {
       copter.throttle = 2;
     }
     if(copter.throttle < 0)
     {
       copter.throttle = 0;
     }
     if(copter.aileron > 0.5)
     {
       copter.aileron = 0.5;
     }
     if(copter.aileron < -0.5)
     {
       copter.aileron = -0.5;
     }
     if(copter.elevator > 0.5)
     {
       copter.elevator = 0.5;
     }
     if(copter.elevator < -0.5)
     {
       copter.elevator = -0.5;
     }
     if(copter.rudder > 0.5)
     {
        copter.rudder = 0.5;
     }
     if(copter.rudder < -0.5)
     {
        copter.rudder = -0.5;
     }   
     

  if(mode == 1)//if leap mode
  {
  if(finger_detected == 0){
  if(stabilisation == 0)
  {
    copter.elevator = copter.aileron = 0;
    if(copter.throttle > 0)
    {
      copter.throttle -= stepSize;
      if (millis() - lastTime > timeToWait)
          {
            copter.throttle -= stepSize;
            lastTime = millis();
          }
    }
  }
  }
  }
  if(etat == 2) //if control off
    {
      if(copter.throttle > 0)
      {
          copter.elevator = 0;
          copter.aileron = 0;
          copter.rudder = 0;
          //self landing timing
          if (millis() - lastTime > timeToWait)
          {
            copter.throttle -= stepSize;
            lastTime = millis();
          }
          
      }
     copter.elevator = 0;
     copter.aileron = 0;
     copter.rudder = 0;
    }

}//end of void draw()

  void leapOnKeyTapGesture(KeyTapGesture g){ //KeyTap Gesture Function
  int       id               = g.getId();
  Finger    finger           = g.getFinger();
  PVector   position         = g.getPosition();
  PVector   direction        = g.getDirection();
  long      duration         = g.getDuration();
  float     duration_seconds = g.getDurationInSeconds();
  
  println("KeyTapGesture: "+id);
  if(etat == 1)//if control activated
  {
    if(mode == 1)//if mode Leap
    {
  switch(rudder_enabled){ //enables/disables rudder with keyTap

  case 0:
  rudder_enabled = 1;
  println("Rudder control disabled");
  break;
  
  case 1:
  rudder_enabled = 0;
  println("Rudder control disabled");
  break;
 
  }//end if etat
  }//end if mode
  }//end of switch
 }//end of keytap
 
  
      void leapOnCircleGesture(CircleGesture g, int state){ //A function for the circle gesture, may be used to "flip" later on
  int       id               = g.getId();
  Finger    finger           = g.getFinger();
  PVector   position_center  = g.getCenter();
  float     radius           = g.getRadius();
  float     progress         = g.getProgress();
  long      duration         = g.getDuration();
  float     duration_seconds = g.getDurationInSeconds();

  switch(state){
    case 1: // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      println("CircleGesture: "+id);
      break;
      
  } //end of switch state
    } //end of circle gesture

//beginning of the keyboard control code section
void keyPressed() {
  float stepSize=0.01;
  float stepSizekey=0.06;
   if (key == '4')
  {
    switch(throttle_lock)
    {
    case 0:
    throttle_lock = 1;
    println("Throttle is locked");
    break;
    
    case 1:
    throttle_lock = 0;
    println("Throttle is unlocked");
    break;
    }
  }
  //rudder control on/off
  if (key == '3') {
    switch(rudder_enabled)
    {
      case 0:
      rudder_enabled = 1;
      println("Rudder control enabled");
      break;
      
      case 1:
      rudder_enabled = 0;
      println("Rudder control disabled");
      break;
    }
  }
  //switch stabilisation on/off
  if (key == '2') {
    switch(stabilisation)
    {
      case 0:
      stabilisation = 1;
      println("Stabilisation on");
      break;
      
      case 1:
      stabilisation = 0;
      println("Stabilisation off");
      break;
    }
  }
  //switch keyboard mode on/off
  if (key == '1') {
    switch(mode)
    {
      case 1:
      copter.aileron=0;
      copter.elevator=0;
      copter.throttle=1;
      mode = 2;
      println("Keyboard mode");
      break;
      
      case 2:
      mode = 1;
      println("Leap mode");
      break;
    }
  }
  //had to use logic operator !, dunno why it doesn't work with ==
if(etat !=2){//if control on
    if(mode !=1){//if keyboard mode
      if(stabilisation != 1)//if stabilisation off
      {
  if (key == 'a') {
    copter.throttle += stepSizekey;
    if(copter.throttle > 2)//maximum value
    {
      copter.throttle = 2;
    }
    
    println("Copter throttle ="+copter.throttle);
  }
  if (key == 'z') {
    copter.throttle -= stepSizekey;
    if (copter.throttle < 0)//minimum value
    {
      copter.throttle = 0;
    }
    println("Copter throttle ="+copter.throttle);
  }
  if (key == 'A' || key == 'Z') {
    copter.throttle = 0;
    println("Copter throttle ="+copter.throttle);
  }
}//end of if stab off
}//end of if keyboard mode
  }//end of if control on
  
  //switch control on/off
  if (key == '0') {
    switch(etat)
    {
      case 1:
      etat = 2;
      println("Control activated");
      break;
      
      case 2:
      etat = 1;
      println("Control desactivated");
      break;
    }
  }
  //settings of precision
  if (key == '+') {
    precisionMultiplicator = precisionMultiplicator+5;
  }
  if (key == '-') {
    precisionMultiplicator = precisionMultiplicator-5;
  } 
if(etat !=2){//if control on
    if(mode !=1){//if keyboard mode
      if(stabilisation != 1)//if stab off
      {
  if (key == CODED) {
    if (keyCode == UP) {
      copter.elevator+=stepSizekey;
      if (copter.elevator > 0.5)
      {
        copter.elevator = 0.5;
      }
      
      println("Copter elevator ="+copter.elevator);
    } 
    else if (keyCode == DOWN) {
      copter.elevator-=stepSizekey;
      if (copter.elevator < -0.5)
      {
        copter.elevator = -0.5;
      }
      println("Copter elevator ="+copter.elevator);
    } else    if (keyCode == RIGHT) {
      copter.aileron+=stepSizekey;
      if(copter.aileron > 0.5)
      {
        copter.aileron = 0.5;
      }
      println("Copter aileron ="+copter.aileron);
    } 
    else if (keyCode == LEFT) {
      copter.aileron-=stepSizekey;
      if(copter.aileron < -0.5)
      {
        copter.aileron = -0.5;
      }
      println("Copter aileron ="+copter.aileron);
    
    }
  }
}//end of if stab off
}//end of if keyboard mode
}  //end of if control on 
} //end of void keyPressed function
