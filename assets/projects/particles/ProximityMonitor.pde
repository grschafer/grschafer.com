//
// This class holds a list of all balls.
// It is responsible for making connections
// between balls when they are close enough
//

public class ProximityMonitor {
  
  private static final int BLUE_AND_BLUE = 2;
  private static final int BLUE_AND_GREEN = 3;
  private static final int BLUE_AND_RED = 5;
  private static final int BLUE_AND_PURPLE = 9;
  private static final int GREEN_AND_GREEN = 4;
  private static final int GREEN_AND_RED = 6;
  private static final int GREEN_AND_PURPLE = 10;
  private static final int RED_AND_RED = 8;
  private static final int RED_AND_PURPLE = 12;
  private static final int PURPLE_AND_PURPLE = 16;
  
  private ArrayList<Ball> balls;
  private FWorld world;
  
  public ProximityMonitor(FWorld world) {
    this.world = world;
    balls = new ArrayList<Ball>();
  }
  
  // Note: to be called every frame
  // checks balls' proximities and connects them if they're close enough
  public void monitor() {
    for (int i = 0; i < balls.size() - 1; i++) {
      for (int j = i + 1; j < balls.size(); j++) {
        if (!balls.get(i).isConnectedTo(balls.get(j))) {
          react(balls.get(i), balls.get(j));
          
          // for displaying molecule membership on screen
          if (debugMode)
          {
            textFont(font16);
            fill(128,128,128);
            for (Ball b : balls)
              if (b.getParentMolecule() != null)
                text(b.getParentMolecule().name, b.getX()+b.getSize()/2, b.getY());
          }
        }
      }
    }
  }

  private void react(Ball a, Ball b) {
    switch (a.getType() + b.getType()) {
      case BLUE_AND_BLUE:     //fusion(a,b);    break;
      case RED_AND_PURPLE:
      case PURPLE_AND_PURPLE:
      case BLUE_AND_GREEN:
      case BLUE_AND_RED:
      case BLUE_AND_PURPLE:   connect(a,b);   break;
      case RED_AND_RED:
      case GREEN_AND_GREEN:   repel(a,b);     break;
      case GREEN_AND_RED:     attract(a,b);   break;
      case GREEN_AND_PURPLE:  dissolve(a,b);  break;
    }
  }
  
  private void connect(Ball a, Ball b) { connect(a,b,false); }
  private void connect(Ball a, Ball b, boolean force) {
    float connectionDistance = a.getSize() + b.getSize() + CONNECTION_DISTANCE;
    if (force ||
        (a.getRecombinationDelay() < frameCount &&
        b.getRecombinationDelay() < frameCount &&
        dist(a.getX(), a.getY(), b.getX(), b.getY()) < connectionDistance)) {
      FDistanceJoint j = makeJoint(a,b);
      a.connectTo(b);
      b.connectTo(a);
      
      mergeMolecules(a,b,j);
    }
  }
  
  private void repel(Ball a, Ball b) {
    magneticForce(a,b,false);
  }
  
  private void attract(Ball a, Ball b) {
    magneticForce(a,b,true);
  }
  private void magneticForce(Ball a, Ball b, boolean attract) {
    PVector v = new PVector(a.getX() - b.getX(), a.getY() - b.getY());
    
    float distance = v.mag();
    v.normalize();
    // force depends on distance and mass (size) of balls involved
    v.mult(3 * (a.getSize() + b.getSize()) / pow(distance / 100, 2));
    
    
    // if force is too small, ignore it
    if (v.mag() > 20) {
      if (attract) {
        a.addForce(-v.x, -v.y);
        b.addForce(v.x, v.y);
        if (debugMode) {
          stroke(0,200,0);
          line(a.getX(), a.getY(), a.getX() - v.x, a.getY() - v.y);
          line(b.getX(), b.getY(), b.getX() + v.x, b.getY() + v.y);
        }
      }
      else {
        a.addForce(v.x, v.y);
        b.addForce(-v.x, -v.y);
        if (debugMode) {
          stroke(200,0,0);
          line(a.getX(), a.getY(), a.getX() + v.x, a.getY() + v.y);
          line(b.getX(), b.getY(), b.getX() - v.x, b.getY() - v.y);
        }
      }
    }
  }
  
  private void dissolve(Ball a, Ball b) {
    float dissolveDistance = a.getSize() + b.getSize() + CONNECTION_DISTANCE;
    if (dist(a.getX(), a.getY(), b.getX(), b.getY()) < dissolveDistance) {
      Molecule molA = a.getParentMolecule();
      Molecule molB = b.getParentMolecule();
      if (molA != null) {
        molA.dissolve();
      }
      if (molB != null) {
        molB.dissolve();
      }
      a.setType(Ball.BLUE);
      b.setType(Ball.BLUE);
    }
  }
  
  // can't have balls inside each other
  // remove from world erases joints
  // STILL HAVING SOME ISSUE WHERE JOINTS ARE REMOVED FROM WORLD BUT NOT ALL REFERENCES ARE REMOVED
  private void fusion(Ball a, Ball b) {
    if (a.isTouchingBody(b)) {
      println("fusing");
      if (a.getSize() < b.getSize()) {
        a.setPosition(b.getX(), b.getY());
      }
      a.setForce((a.getForceX() + b.getForceX()) / 2, (a.getForceY() + b.getForceY()) / 2);
      a.setSize(a.getSize() + b.getSize());
      
      if (b.getParentMolecule() != null) {
        println("making " + b.getConnections().size() + " connections");
        b.getParentMolecule().removeBall(b);
        for (Ball c : b.getConnections()) {
          c.getConnections().remove(b);
          connect(a,c,true);
        }
      }
      if (a.getParentMolecule() != null) {
        for (Ball c : b.getConnections()) {
          c.setParentMolecule(a.getParentMolecule());
        }
      }
      b.getConnections().clear();
      balls.remove(b);
      b.removeFromWorld();  // also removes all of its joints from the world
      b.setNoStroke();
      b.setNoFill();
    }
  }
  
  private void fission(Ball a, Ball b) {
    ;
  }
  
  // this doesn't really belong in the ProximityMonitor  =\
  private Molecule mergeMolecules(Ball a, Ball b, FDistanceJoint j) {
    Molecule molA = a.getParentMolecule();
    Molecule molB = b.getParentMolecule();
    
    // the case where molA == molB is handled in Molecule.merge()
    if (molA != null && molB != null) {
      molA.merge(molB,j);
      return molA;
    }
    else if (molA != null) {
      molA.addConnection(b,j);
      return molA;
    }
    else if (molB != null) {
      molB.addConnection(a,j);
      return molB;
    }
    else {
      return new Molecule(a,b,j);
    }
  }
  
  private FDistanceJoint makeJoint(Ball a, Ball b) {
    FDistanceJoint j = new FDistanceJoint(a,b);
    j.setAnchor1(0, 0);
    j.setAnchor2(0, 0);
    j.calculateLength();
    j.setDrawable(true);
    
    j.setDamping(1000);
    j.setStroke(192);
    j.setFill(64);    // if both balls are same color, color that connector the same?
    world.add(j);
    return j;
  }
  public void add(Ball b) {
    balls.add(b);
  }
  
  public void clear() {
    balls = new ArrayList<Ball>();
  }
}
