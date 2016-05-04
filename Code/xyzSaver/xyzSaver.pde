import java.io.BufferedWriter;
import java.io.FileWriter;
import processing.serial.*;
import static javax.swing.JOptionPane.*;

final boolean debug = true;

String finalData[], tempFinalData;
String savePath;

Serial myPort;
 
void setup() {
  size(100, 100);
  
  savePath = showInputDialog("Enter path of where data is to be saved:");
  
  String s = "Processing Data Now";
  fill(50);
  text(s, 10, 10, 80, 80);                         // Text wraps within text box
  String serialX, serialList = ""; 
  try {                                            //the following process will list all the serial ports available on computer
    if(debug) printArray(Serial.list());
    int i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
                                                   // need to check which port the inst uses -
                                                   // for now we'll just let the user decide
        for (int j = 0; j < i;) {
          serialList += char(j+'a') + " = " + Serial.list()[j];
          if (++j < i) serialList += "\n";
        }
        serialX = showInputDialog("Which Serial port is correct? (a,b,..):\n"+serialList);
        if (serialX == null) exit();
        if (serialX.isEmpty()) exit();
        i = int(serialX.toLowerCase().charAt(0) - 'a') + 1;
      }
      String portName = Serial.list()[i-1];
      if(debug) println(portName);
      myPort = new Serial(this, portName, 115200); // change baud rate to your liking
      myPort.bufferUntil('\n');                    // buffer until CR/LF appears, but not required..
    }
    else {
      showMessageDialog(frame,"Device is not connected to the PC");
      exit();
    }
  }
  catch (Exception e)
  {                                               // Print the type of error
    showMessageDialog(frame,"Serial port is not available (might be in use by another program)");
    println("Error:", e);
    exit();
  }

}

void draw(){}                                      // field is empty as the program is based of serialEvent,
                                                   // draw() is only needed to loop the program 

void serialEvent(Serial serialPort) {
     
  String tempString = serialPort.readString();     // reads the data on serial from the arduino and sensor
  tempString = trim(tempString);
  
  if (tempString != "Done,Done,Done"){

    String tempArray[] = tempString.split(",");
    float tempR = sqrt(sq(Float.valueOf(tempArray[0])) - 9) + 6;  //Distance calibration to device - Radius
    float tempTheta = radians(Float.valueOf(tempArray[1]));       //Convert to Radians - Inclination
    float tempPhi = radians(Float.valueOf(tempArray[2]));         //Convert to Radians - Azimuth

    PVector v = XYZ(tempR, tempTheta, tempPhi);

    String writableString = v.x +","+v.y+","+v.z;
    writableString = writableString.substring(0, writableString.length() - 1);
    tempFinalData += writableString + "|"; 
    }
   else {
     
    finalData = tempFinalData.split("|");
   
    try {
     FileWriter fw = new FileWriter(savePath);     //Creates a new file for data to be saved to
     BufferedWriter bw = new BufferedWriter(fw);
     
     for (int i = 0; i< finalData.length; i++){
       bw.write(finalData[i]);
       bw.newLine();
     }
     bw.close();
     showMessageDialog(frame, "Finished Processing Data, open 3D Mapper\nto see data visualised"); 
    exit();
  }
    catch(IOException e) {
  println("It Broke");
  e.printStackTrace();
  } 
  }
 }

void mousePressed(){
 myPort.write(1+".");                            // Writes to serial to initiate the program on
}                                                // the arduino of get_distance on a mouse click

PVector XYZ(float r, float theta, float phi) {
  float vx = r*cos(theta)*cos(phi);              // Calculates the X axis coordinate
  float vy = r*sin(theta);                       // Calculates the Y axis coordinate
  float vz = r*sin(phi)*cos(theta);              // Calculates the Z axis coordinate
  PVector  v = new PVector(vx, -vy , vz);        // Creates a vector point in cartesian form
  return v;
}