/*
IHC 
 
 Jorge C. S. Cardoso
 */

import KinectPV2.*;

int GRID_SIZE = 80;
long MOVEMENT_THRESHOLD = 30;

KinectPV2 kinect;

float rotX = 0;
float rotY = 0;
float zoom = 1;

// depth data from previous frame
int previousRawData[];


int countFramesWithNoMovement = 0;


int toMesh[];
int fromMesh[];

int previousDepthData[];


float percent = 0;


void setup() {
  size(1024, 848, P3D);
  frameRate(30);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableInfraredImg(true);
  kinect.enableInfraredLongExposureImg(false);
  kinect.init();

  previousRawData = new int[KinectPV2.WIDTHDepth*KinectPV2.HEIGHTDepth];

  previousDepthData = new int[KinectPV2.WIDTHDepth*KinectPV2.HEIGHTDepth];

  toMesh = new int[GRID_SIZE*GRID_SIZE];
  fromMesh = new int[GRID_SIZE*GRID_SIZE];


  colorMode(HSB);
}


void draw() {
  background(0);


  //raw Data int valeus 
  int [] rawData = arraySample(kinect.getRawDepthData(), KinectPV2.WIDTHDepth, KinectPV2.HEIGHTDepth, GRID_SIZE, GRID_SIZE);


  int [] diffDepthData = arrayDiff(rawData, previousRawData);

  long qtdMovement = arraySumAbsElements(diffDepthData)/(GRID_SIZE*GRID_SIZE);

  // save current depth for next frame
  arrayCopy(rawData, previousRawData);


  if (qtdMovement < MOVEMENT_THRESHOLD) {
    countFramesWithNoMovement++;
  } else {
    countFramesWithNoMovement = 0;
  }

  println("Quantity of Movement: " + qtdMovement);

  // trigger 'event'
  if (countFramesWithNoMovement == 15) { // half a second
    println("Triggering mesh update");

    arraycopy(toMesh, fromMesh);
    arrayCopy(rawData, toMesh);
    percent = 0;
    //updateMesh(rawData);
  } 

  background(0);
  lights();

  text( frameRate+"", 100, 100);

  translate(width/2, height/2, 0);
  rotateY(radians(rotY));
  rotateX(radians(rotX));
  scale(zoom);
  drawMeshTriangles(toMesh, fromMesh, diffDepthData, percent, GRID_SIZE);

  percent += 0.01;
  percent = constrain(percent, 0, 1);
  // println(frameRate);
}



/*

 p1-------p2
 |     .  |
 |   .    |
 | .      |
 p3-------p4
 
 */

void drawMeshTriangles(int []toMesh, int []fromMesh, int[] diff, float percent, int gridSize) {

  /*for ( int i = 0; i < toMesh.length; i++ ) {
   toMesh[i] = fromMesh[i] = 2000;
   }*/
  for ( int i = 0; i < toMesh.length; i++ ) {
    int l = i/gridSize;
    int c = i%gridSize;

    if (l == gridSize-1) continue;
    if (c == gridSize-1) continue;
    int i1 = i;
    int i2 = l*gridSize+(c+1);
    int i3 = (l+1)*gridSize + c;
    int i4 = (l+1)*gridSize + (c+1);


    float x1 = -10*GRID_SIZE/2+(c)*10;
    float y1 = -10*GRID_SIZE/2+(l)*10;
    float z1 =  map(fromMesh[ i1 ]+percent*(toMesh[ i1 ] - fromMesh[ i1 ]), 0, 8000, 0, 200);

    float x2 = -10*GRID_SIZE/2+(c+1)*10;
    float y2 = -10*GRID_SIZE/2+(l)*10;
    float z2 =  map(fromMesh[ i2 ]+percent*(toMesh[ i2 ] - fromMesh[ i2 ]), 0, 8000, 0, 200);

    float x3 = -10*GRID_SIZE/2+(c)*10;
    float y3 = -10*GRID_SIZE/2+(l+1)*10;
    float z3 =  map(fromMesh[ i3 ]+percent*(toMesh[ i3 ] - fromMesh[ i3 ]), 0, 8000, 0, 200);

    float x4 = -10*GRID_SIZE/2+(c+1)*10;
    float y4 = -10*GRID_SIZE/2+(l+1)*10;
    float z4 =  map(fromMesh[ i4 ]+percent*(toMesh[ i4 ] - fromMesh[ i4 ]), 0, 8000, 0, 200);

    if ( abs(diff[i]) > 100) {
      stroke(0, 255, 255);
    } else {
      stroke(0, 0, 255);
    }

    beginShape(TRIANGLE);

    fill(map(z1, 0, 200, 0, 255), 255, 255); 
    vertex(x1, y1, -z1);
    vertex(x2, y2, -z2);
    vertex(x3, y3, -z3);
    endShape();

    beginShape(TRIANGLE);
    vertex(x2, y2, -z2);
    vertex(x4, y4, -z4);
    vertex(x3, y3, -z3);
    endShape();
  }
}



// Returns the difference between to arrays 
int[] arrayDiff(int []rawData, int []previousRawData) {
  int[] diff = new int[rawData.length];  
  for ( int i = 0; i < rawData.length; i++ ) {
    diff[i] = rawData[i] - previousRawData[i];
  }
  return diff;
}


// Returns the sum of the absolute values of each element in a[]
long arraySumAbsElements(int []a) {
  long sum = 0;
  for (int v : a) {
    sum += abs(v);
  }
  return sum;
}

// Returns the sum of the absolute values of each element in a[]
long arrayMax(int []a) {
  long max = 0;
  for (int v : a) {
    if ( max < v) max = v;
  }
  return max;
}

int [] arraySample(int[]depthData, int depthDataWidth, int depthDataHeight, int newWidth, int newHeight) {
  int [] sampled = new int[newWidth*newHeight];

  for ( int l = 0; l < newHeight; l++ ) {
    for ( int c = 0; c < newWidth; c++) {
      int originalL = depthDataHeight*l/newHeight;
      int originalC = depthDataWidth*c/newWidth;
      sampled[l*newWidth+c] = depthData[originalL*depthDataWidth+originalC];
    }
  }
  return sampled;
}

void mouseDragged() {
  if ( mouseButton == RIGHT ) {
    zoom += map(mouseY-pmouseY, 0, height, 0, 2);
  } else {
    rotX += map(mouseY-pmouseY, 0, height, 0, 360);
    rotY += map(mouseX-pmouseX, 0, width, 0, 360);
  }
}

void exit() {
  println("Stopping");
  kinect.dispose();

  super.exit();
}