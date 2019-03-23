import processing.serial.*;

Serial port;
String strX, strY, strZ;
String rotA = "0.0";
String rotB = "0.0";
String rotC = "0.0";

float GX, GY, GZ;

float rotX = 0.0;
float rotY = 0.0;
float rotZ = 0.0;

int time = 0;

int N = 1000;
int[] x = new int[N];
int[] y = new int[N];
int[] z = new int[N];
float[] a = new float[N];
float[] b = new float[N];
float[] c = new float[N];

float xr = 0;
float yr = 0;
float zr = 0;

void setup() {
  String[] portList = Serial.list();
  String portName = null;
  for(int i=0; i < portList.length; i++) {
    if(match(portList[i], "COM6")!=null) {
      portName = portList[i];
    }
  }
  if(portName!=null) {
    port = new Serial(this, portName, 230400);
  }else {
    print("Port initialization error.");
  }
  //GRAPHICS INIT
  size(1080, 640, P3D);
  background(0);
  noFill();
  stroke(255);
  strokeWeight(1);
  smooth();
  for(int n=0; n<N; n++) {
    x[n] = 0;
    y[n] = 0;
    z[n] = 0;
    a[n] = 0;
    b[n] = 0;
    c[n] = 0;
  }
}

void draw() {
  translate(width/2, height/2);
  background(0);
  if((rotA!=null)&&(rotB!=null)&&(rotC!=null)) {
    rotX = float(rotA);
    rotY = float(rotB);
    rotZ = float(rotC);
  }
  rotateX(xr);
  rotateY(yr);
  rotateZ(zr);
  //
  for(int i = N-1; i>0; i--) {
    x[i] = x[i-1];
    y[i] = y[i-1];
    z[i] = z[i-1];
    a[i] = a[i-1];
    b[i] = b[i-1];
    c[i] = c[i-1];
  }  
  if(port!=null) {
    //DATA COLLECTING AND PREPROCESSING
    if((port.available() > 0)) {
      strX = port.readStringUntil('\n');
      strY = port.readStringUntil('\n');
      strZ = port.readStringUntil('\n');
      rotA = port.readStringUntil('\n');
      rotB = port.readStringUntil('\n');
      rotC = port.readStringUntil('\n');
      //
      if((strX!=null)&&(strY!=null)&&(strZ!=null)) {
        float vect = 50.0;
        float cosDoUsrednienia = 2.0;
        GX = float(strX);
        GY = float(strY);
        GZ = float(strZ);
        x[0] = int(GX/vect);
        y[0] = int(GY/vect);
        z[0] = int(GZ/vect);
        a[0] = rotX/cosDoUsrednienia;
        b[0] = rotY/cosDoUsrednienia;
        c[0] = rotZ/cosDoUsrednienia;
        print(GX+"  "+GY+"  "+GZ+"  "+x[0]+"  "+y[0]+"  "+z[0]+"\n");
        print(rotX+"  "+rotY+"  "+rotZ+"  "+a[0]+"  "+b[0]+"  "+c[0]+"\n");
        //print(x[0]+" "+y[0]+" "+z[0]+"\n");
        //print(GX+" "+GY+" "+GZ+"\n");
        //print(strX+strY+strZ);
        time++;
      }
      //GAUNTLET ROTATION
      /*
      if((rotA!=null)&&(rotB!=null)&&(rotC!=null)) {
        
        rotateX(float(rotA));
        rotateY(float(rotB));
        rotateZ(float(rotC));
      }*/
    }
  }
  //
  //MOUSE AXIS ROTATION
  /*if(mouseButton==LEFT) {
    rotateY((mouseX-width/2.0)/100.0);
    rotateX((-mouseY+height/2.0)/100.0);
  }*/
  //
  //AXES AND NAMES
  noStroke();
  strokeWeight(1);
  drawAxes(300.0);
  drawSphere(0,0,0,2);
  stroke(255);
  //
  //DRAWING POINTS
  strokeWeight(3);
  for(int i = 0; i<N; i++) {
    float colCtrl = (1 - (float)i/N);
    float intnst = sqrt(x[i]*x[i] + y[i]*y[i] + z[i]*z[i]);
    int limit = 255;
    stroke(limit*colCtrl*abs(x[i])/intnst, limit*colCtrl*abs(y[i])/intnst, limit*colCtrl*abs(z[i])/intnst);
    point(x[i], y[i], z[i]);
  }
  //ballDrop();
  //RED AVERAGE DOT DRAWING
  float xi, yi, zi;
  xi = 0.0;
  yi = 0.0;
  zi = 0.0;
  int ease = 20; //NUMBER OF POINTS USED TO AVERAGE
  for(int n = 0; n<ease; n++) {
    xi+=x[n];
    yi+=y[n];
    zi+=z[n];
  }
  xi /= ease;
  yi /= ease;
  zi /= ease;
  strokeWeight(8);
  stroke(255,0,0);
  point(xi,yi,zi);
  //
  //AVERAGING ROTATION
  xr = 0.0;
  yr = 0.0;
  zr = 0.0;
  int easeR = 20; //NUMBER OF POINTS USED TO AVERAGE
  for(int n = 0; n<easeR; n++) {
    xr+=a[n];
    yr+=b[n];
    zr+=c[n];
  }
  xr /= easeR;
  yr /= easeR;
  zr /= easeR;
}
//
//CENTRAL SPHERE 
void drawSphere(float x, float y, float z, float r) {
  noStroke();
  fill(255,255,255);
  translate(x,y,z);
  sphere(r);
}
//COSMETIC PART - AXIS
void drawAxes(float size){
  stroke(255);
  //X  - red
  stroke(255,0,0);
  text("X", 300, 0, 0);
  line(0,0,0,size,0,0);
  //X' - magenta
  stroke(255,0,255);
  text("-X", -300, 0, 0);
  line(0,0,0,-size,0,0);
  //Y - green
  stroke(0,255,0);
  text("Y", 0, 300, 0);
  line(0,0,0,0,size,0);
  //Y' - yellow
  stroke(255,255,0);
  text("-Y", 0, -300, 0);
  line(0,0,0,0,-size,0);
  //Z - blue
  stroke(0,0,255);
  text("Z", 0, 0, 300);
  line(0,0,0,0,0,size);
  //Z' - cyan
  stroke(0,255,255);
  text("-Z", 0, 0, -300);
  line(0,0,0,0,0,-size);
}
/*
void drawPoint(int x, int y, int z, int n) {
  float colCtrl = (1 - (float)n/N);
  float intnst = sqrt(x*x + y*y + z*z);
  int limit = 255;
  stroke(limit*colCtrl*abs(x)/intnst, limit*colCtrl*abs(y)/intnst, limit*colCtrl*abs(z)/intnst);
  point(x, y, z);
}

void ballDrop() {
  float h = PI/100.0;
  float Rad = 100;
  for(float u = 0; u<2*PI; u+=h) {
    for(float t = 0; t<2*PI; t+=h) {
      float p = Rad*cos(u)*cos(t);
      float q = Rad*cos(u)*sin(t);
      float r = Rad*sin(u);
      drawPoint((int)p, (int)q, (int)r, 1);
    }
  }
}
*/
