import de.voidplus.dollar.*;
import java.util.*;

OneDollar leftHandRecog, rightHandRecog;

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;


float waxOn = 0;
float waxOff = 0;

void setup() {
  size(960, 540, P3D);

  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();



  leftHandRecog = new OneDollar(this);
  println(leftHandRecog);                  // Print all the settings
  leftHandRecog.setVerbose(true);          // Activate console verbose

  // 2. Add gestures (templates):
  leftHandRecog.learn("circleLeft", new int[] {127, 141, 124, 140, 120, 139, 118, 139, 116, 139, 111, 140, 109, 141, 104, 144, 100, 147, 96, 152, 93, 157, 90, 163, 87, 169, 85, 175, 83, 181, 82, 190, 82, 195, 83, 200, 84, 205, 88, 213, 91, 216, 96, 219, 103, 222, 108, 224, 111, 224, 120, 224, 133, 223, 142, 222, 152, 218, 160, 214, 167, 210, 173, 204, 178, 198, 179, 196, 182, 188, 182, 177, 178, 167, 170, 150, 163, 138, 152, 130, 143, 129, 140, 131, 129, 136, 126, 139} );

  // 3. Bind templates to methods (callbacks):
  leftHandRecog.bind("circleLeft", "detectedLeft");

  rightHandRecog = new OneDollar(this);

  println(rightHandRecog);                  // Print all the settings
  rightHandRecog.setVerbose(true);          // Activate console verbose

  // 2. Add gestures (templates):
  rightHandRecog.learn("circleRight", new int[] {127, 141, 124, 140, 120, 139, 118, 139, 116, 139, 111, 140, 109, 141, 104, 144, 100, 147, 96, 152, 93, 157, 90, 163, 87, 169, 85, 175, 83, 181, 82, 190, 82, 195, 83, 200, 84, 205, 88, 213, 91, 216, 96, 219, 103, 222, 108, 224, 111, 224, 120, 224, 133, 223, 142, 222, 152, 218, 160, 214, 167, 210, 173, 204, 178, 198, 179, 196, 182, 188, 182, 177, 178, 167, 170, 150, 163, 138, 152, 130, 143, 129, 140, 131, 129, 136, 126, 139} );

  // 3. Bind templates to methods (callbacks):
  rightHandRecog.bind("circleRight", "detectedRight");
}


// 4. Implement callbacks:
void detectedLeft(String gesture, float percent, int startX, int startY, int centroidX, int centroidY, int endX, int endY) {
  println("Gesture Left: "+gesture+", "+startX+"/"+startY+", "+centroidX+"/"+centroidY+", "+endX+"/"+endY);

  waxOn = 1;
}

void detectedRight(String gesture, float percent, int startX, int startY, int centroidX, int centroidY, int endX, int endY) {
  println("Gesture Right: "+gesture+", "+startX+"/"+startY+", "+centroidX+"/"+centroidY+", "+endX+"/"+endY);

  waxOff = 1;
}

void draw() {
  background(0);

  pushMatrix();

  image(kinect.getColorImage(), 0, 0, width, height);
  scale(0.5);
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col, 150);
      stroke(col);
      drawBody(joints);

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      rightHandRecog.track(joints[KinectPV2.JointType_HandRight].getY(), joints[KinectPV2.JointType_HandRight].getX());
      leftHandRecog.track(joints[KinectPV2.JointType_HandLeft].getX(), joints[KinectPV2.JointType_HandLeft].getY());
    }
  }


  popMatrix();
  fill(255, waxOn>0.5 ? 255 : 255*waxOn);
  textSize(waxOn>0.5 ? (1-waxOn)*200+50 : (waxOn*200+50));
  text("Wax On", (width-textWidth("WaxOn"))/2, height/2);

  waxOn -= 0.03;
  waxOn = constrain(waxOn, 0, 1);

  fill(255,  waxOff>0.5 ? 255 : 255*waxOff);
  textSize(waxOff>0.5 ? (1-waxOff)*200+50 : (waxOff*200+50));
  text("Wax Off", (width-textWidth("Wax Off"))/2, height/2);

  waxOff -= 0.03;
  waxOff = constrain(waxOff, 0, 1);

  fill(255, 0, 0);
  textSize(20);
  text(frameRate, 50, 50);
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}