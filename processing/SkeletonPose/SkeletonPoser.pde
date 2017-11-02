/*
Adapted from "Making Things See" book.
 
 pose.addRule(SimpleOpenNI.LEFT_HAND, SkeletonPoser.ABOVE, SimpleOpenNI.LEFT_ELBOW);
 pose.addRule(SimpleOpenNI.LEFT_HAND, SkeletonPoser.LEFT_OF, SimpleOpenNI.LEFT_ELBOW);
 
 */

class SkeletonPoser {
  KinectPV2 context;
  ArrayList rules;


  SkeletonPoser(KinectPV2 context) {
    this.context = context;
    rules = new ArrayList();
  }

  void addRule(int fromJoint, int jointRelation, int toJoint) {
    PoseRule rule = new PoseRule(context, fromJoint, jointRelation, toJoint);
    rules.add(rule);
  }

  boolean check(int userID) {
    boolean result = true;
    for (int i = 0; i < rules.size(); i++) {
      PoseRule rule = (PoseRule)rules.get(i);
      result = result && rule.check(userID);
    }
    return result;
  }
}

class PoseRule {
  int fromJoint;
  int toJoint;
  KJoint fromJointVector;
  KJoint toJointVector;
  KinectPV2 context;

  int jointRelation; // one of:  
  static final int ABOVE     = 1;
  static final int BELOW     = 2;
  static final int LEFT_OF   = 3;
  static final int RIGHT_OF  = 4;

  PoseRule(KinectPV2 context, int fromJoint, int jointRelation, int toJoint) {
    this.context = context;
    this.fromJoint = fromJoint;
    this.toJoint = toJoint;
    this.jointRelation = jointRelation;

    //fromJointVector = new PVector();
    //toJointVector = new PVector();
  }

  boolean check(int userID) {

    ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(userID);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      fromJointVector = joints[fromJoint];
      toJointVector = joints[toJoint];



      // populate the joint vectors for the user we're checking
      //context.getJointPositionSkeleton(userID, fromJoint, fromJointVector);
      //context.getJointPositionSkeleton(userID, toJoint, toJointVector);

      boolean result = false;

      switch(jointRelation) {
      case ABOVE:
        result = (fromJointVector.getY() < toJointVector.getY());
        break;
      case BELOW:
        result = (fromJointVector.getY() > toJointVector.getY());
        break;
      case LEFT_OF:
        result = (fromJointVector.getX() < toJointVector.getX());
        break;
      case RIGHT_OF:
        result = (fromJointVector.getX() > toJointVector.getX());
        break;
      }

      return result;
    }

    return false;
  }
}