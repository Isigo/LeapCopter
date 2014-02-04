class PIDController {
  float kP=0, kI =0, kD =0;
  float maxOutput=0, minOutput=0;
  float setPoint = 0;
  float integral =0;
  float lastError =0;
  // Could just be method local, 
  // but handy to have em accessible for debugging
  float error =0, derivative =0, output = 0;
  
  public float updateProcess(float dt, float measuredValue) {
    error = setPoint -   measuredValue;
    integral = integral + error*dt;
    derivative = (error - lastError)/dt;
    output = kP*error + kI*integral + kD*derivative;
    lastError = error;
    return clamp(output, minOutput, maxOutput);
  }
}

class ElevatorPID extends PIDController {
  float kP=0.5 ; // divide by GroundControl.width / 2 ;
  float kD=0; float kI=kP;
  float minOutput = -0.15, maxOutput = -minOutput;
}

// PI controller expecting altitude as input, 
// and returning suggested velocity.  
// All in units approximating m/s
class AltitudePI extends PIDController {
  float kP=0.4, kI=0.4, kD=0;
  float minOutput=-1, maxOutput = 1;
}

// PD controller expecting climb_rate as input and setpoint
// and throttle as output
class ThrottlePID extends PIDController {
  float kP=0.34, kI=0, kD=0.02;
  float minOutput = 0.1, maxOutput = 0.9;
}
