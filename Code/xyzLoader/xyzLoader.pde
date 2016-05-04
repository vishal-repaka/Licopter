import static javax.swing.JOptionPane.*;

float x, y, z;
float rotX, rotY;
String values[];

void setup(){
 size(800,800,P3D);

 values = loadStrings(showInputDialog("Input File to be loaded:"));
 
}

void draw(){

 background(0);
 translate(width/2, height/2);
 rotateY(rotY);
 rotateX(rotX);
 randomSeed(10);
  for (int i=0; i< values.length; i++){
    PVector v = plotter(i);
    v.mult(1);                            // Scales the Vector Points
    float r = sqrt(sq(x) +sq(y) +sq(z));  // Finds the radius to map the colour according to distance
    stroke(255,map(r,0,200, 0,255),0);     
    strokeWeight(4);
    point(v.x, v.y, v.z);                 // Plots the vector
   
  }
 
}

void keyPressed(){
 exit(); 
}

PVector plotter(int j){                   // Splits values from text file to create vector
  
  String tempValues[] =  values[j].split(",");
  x = Float.valueOf(tempValues[0]);
  y = Float.valueOf(tempValues[1]);
  z = Float.valueOf(tempValues[2]);
  
  PVector v = new PVector(x, y, z);
  
  return v;
 
}

void mouseDragged()
{
  if (mouseButton == LEFT)
  {
    //navigation style 1
    rotY += (pmouseX - mouseX)*0.01;
    rotX += (pmouseY - mouseY)*0.01;
    //navigation style 2
//    rotX += (mouseX - pmouseX)*0.01;
//    rotY += (mouseY - pmouseY)*0.01;
  }
}