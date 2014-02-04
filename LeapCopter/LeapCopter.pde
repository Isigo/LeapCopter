/**
*Author : Isigo, Avalon Holograph
*Date : 17/13/2013
*Last update : 19/13/2013
*************************************************

LeapCopter is a LeapMotion application made for controlling a quadcopter Hubsan X4 with the LeapMotion controller.
Contact : theo.lucaroni@gmail.com

*************************************************
**/

import de.voidplus.leapmotion.*;
import processing.serial.*;

boolean colour_pick=false, showVideo=false;
CopterModel copter;
CopterVisualisation visual;
int etat = 2;
int mode = 1;
int precisionMultiplicator = 50;
int stabilisation = 1;
long timeToWait = 6;
long lastTime;


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
  PFont font = createFont("SansSerif", 30);      // font setup
  textFont(font);
  textAlign(CENTER, CENTER);
  copter = new CopterModel((PApplet)this);
  visual = new CopterVisualisation(copter, 0, 490, 100);
  lastTime = millis();
  leap = new LeapMotion(this).withGestures("key_tap"); // le leap détecte la gesture key_tap seulement
}
boolean newframe=false;
void draw()
{
  background(255);
  int fps = leap.getFrameRate();
  visual.update();
  copter.sendData();
  float stepSize = 0.01;  //CONTROL LEAP SANS SECURITE
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
    /*println(hand_position);
    text(hand_position.x, 300, 200);
    text(hand_position.y, 300, 250);
    text(hand_position.z, 300, 300);
    handX = hand_position.x/10;
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
      switch(touch_zone)
      {
        case -1:
        break;
        
        case 0:
        hand.draw();
        break;
        
        case 1:
        break;
        
      }
      if(etat == 1)
      {
        if(mode == 1)
        {
          
          if (stabilisation == 1);
          {
            copter.throttle=1;
            copter.elevator=0;
            copter.aileron=0;
           
          }
          if (stabilisation == 0)
          {
          copter.throttle=(hand_position.y/-100)+5.00;
          copter.elevator=(hand_roll/(-1*precisionMultiplicator))+0.15;
          copter.aileron=hand_pitch/(1*precisionMultiplicator);
          }
          
         
        }
      }
     
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
      }       
  }
  if(mode == 1)
  {
  if(finger_detected == 0)
  {
    copter.elevator = copter.aileron = 0;
    if(copter.throttle > 0)
    {
      copter.throttle -= stepSize;
    }
  }
  }
  if(etat == 2)
    {
      if(copter.throttle > 0)
      {
          copter.elevator = 0;
          copter.aileron = 0;
          
          if (millis() - lastTime > timeToWait)
          {
            copter.throttle -= stepSize;
            lastTime = millis();
          }
          
      }
     copter.elevator = 0;
     copter.aileron = 0;
    }

}//Fin du void draw()
void mousePressed() {
  colour_pick=true;
}

void keyPressed() {
  float stepSize=0.01;
  float stepSizekey=0.06;
  
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
  if (key == '1') {
    switch(mode)
    {
      case 1:
      mode = 2;
      println("Mode clavier");
      break;
      
      case 2:
      mode = 1;
      println("Mode Leap");
      break;
    }
  }
if(etat !=2){
    if(mode !=1){
  if (key == 'a') {
    copter.throttle += stepSizekey;
    if(copter.throttle > 2)
    {
      copter.throttle = 2;
    }
    
    println("Copter throttle ="+copter.throttle);
  }
  if (key == 'z') {
    copter.throttle -= stepSizekey;
    if (copter.throttle < 0)
    {
      copter.throttle = 0;
    }
    println("Copter throttle ="+copter.throttle);
  }
  if (key == 'A' || key == 'Z') {
    copter.throttle = 0;
    println("Copter throttle ="+copter.throttle);
  }}
  }
  if (key == '0') {
    switch(etat)
    {
      case 1:
      etat = 2;
      println("Control désactivé");
      break;
      
      case 2:
      etat = 1;
      println("Control activé");
      break;
    }
  }
  if (key == '+') {
    precisionMultiplicator = precisionMultiplicator+5;
  }
  if (key == '-') {
    precisionMultiplicator = precisionMultiplicator-5;
  } 

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
  //}  
  }  //Fin contrôle clavier
  

  
  
}

