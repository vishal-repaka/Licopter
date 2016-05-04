#include <AFMotor.h>
#include <Servo.h> 
#include <NewPing.h>

// DC Servo
Servo servoTheta;

// Stepper Motor Setup
AF_Stepper motor(200, 1);

//Conditions for spherical coordinates 
int stepperPhiDirection = 0;
float stepperPhi = 0;
float r = 0;

// Pin Definitions
#define ECHO_PIN1 A0         // Echo Pin = Analog Pin 0
#define TRIGGER_PIN1 A1      // Trigger Pin = Analog Pin 1
#define LEDPin 13            // Onboard LED
#define servoPin 10

long duration;               // Duration used to calculate distance
long HR_dist=0;              // Calculated Distance
int HR_angle=0;              // The angle in which the servo/sensor is pointing
int HR_dir=1;                // Used to change the direction of the servo/sensor
int minimumRange=5;          //Minimum Sonar range
int maximumRange=150;        //Maximum Sonar Range

NewPing sonar1(TRIGGER_PIN1, ECHO_PIN1, maximumRange); // NewPing setup of pins and maximum distance.


void setup() {
  Serial.begin(115200);      // set up Serial library at 115200 bps

  motor.setSpeed(10);        // stepper motor set to 10 rpm  
  motor.step(200,FORWARD, MICROSTEP);
  motor.step(200,BACKWARD, MICROSTEP);  
  servoTheta.attach(servoPin);
  servoTheta.write(0);
  
 establishContact();
  

}

void loop() {
  
 if (Serial.available()>0){ //Checks for any serial input from Processing Sketch
  servoTheta.write(0);
  
    for(int servoPos=0; servoPos < 86; servoPos+= 5){
     if (stepperPhiDirection == 0){
      for(int i=0; i<100; i++){            //100 steps for 360
         r = getDistance();
         stepperPhi = 3.6*i;
         Serial.print(r);
         Serial.print(",");
         Serial.print(map(servoPos, 0, 85, 0, 90));
         Serial.print(",");
         Serial.println(stepperPhi);
         motor.step(1, FORWARD, MICROSTEP);
       }
       stepperPhiDirection = 1;
     }
     
     else{
       for(int i=0; i<100; i++){            //100 steps for 360
         r = getDistance();
         stepperPhi = 3.6*i;
         Serial.print(r);
         Serial.print(",");
         Serial.print(map(servoPos, 0, 85, 0, 90));
         Serial.print(",");
         Serial.println(stepperPhi);
         motor.step(1, BACKWARD, MICROSTEP); 
       }
       stepperPhiDirection = 0;
     }

     servoTheta.write(servoPos);
    }
    
    Serial.println("Done,Done,Done");
    while(true){}
  }
}

/*--------------------getDistance() FUNCTION ---------------*/
float getDistance(){ 
 
 /* The following trigPin/echoPin cycle is used to determine the
 distance of the nearest object by bouncing soundwaves off of it. */ 
  unsigned int uS1 = sonar1.ping(); // Send ping, get ping time in microseconds (uS).
  
  float HR_dist=uS1 /US_ROUNDTRIP_CM;
  delay(14);
  
 /*Send the reading from the ultrasonic sensor to the computer */
 if (HR_dist >= maximumRange || HR_dist <= minimumRange){
 /* Send a 0 to computer and Turn LED ON to indicate "out of range" */
 digitalWrite(LEDPin, HIGH); 
 } else {
 /* Send the distance to the computer using Serial protocol, and
 turn LED OFF to indicate successful reading. */
 
 digitalWrite(LEDPin, LOW);
 return HR_dist;
 }
}


/*--------------------establishContact() FUNCTION ---------------*/

void establishContact() { //Checks for serial connection from Processing sketch
  while (Serial.available() <= 0) { 
  delay(300);
  }
}
