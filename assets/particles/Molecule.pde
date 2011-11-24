// molecule class

public class Molecule {
  private ArrayList<Ball> balls;
  private ArrayList<FDistanceJoint> connectors;
  public int name;
  
  public Molecule() {
    balls = new ArrayList<Ball>();
    connectors = new ArrayList<FDistanceJoint>();
    name = int(random(0, 10000));
  }
  
  public Molecule(Ball a, Ball b, FDistanceJoint j) {
    this();
    
    a.setParentMolecule(this);
    b.setParentMolecule(this);
    addBall(a);
    addConnection(b, j);
  }
  
  public void dissolve() {
    println("molecule " + name + " has " + balls.size() + " balls and " + connectors.size() + " connectors before dissolving");
    // there's a reference to a joint that is not being removed when that joint is being removed from the world
    for (Iterator<FDistanceJoint> i = connectors.iterator(); i.hasNext(); ) {
      FDistanceJoint j = i.next();
      j.removeFromWorld();
      i.remove();
    }
    PVector v = findCenter();
    stroke(0);
    for (Ball b : balls) {
      b.setRecombinationDelay(frameCount + 20);  // balls can't connect for ~1/3 second
      name = -1;
      b.setParentMolecule(null);
      b.clearConnections();
      b.addForce(200*(b.getX() - v.x), 200*(b.getY() - v.y));
      line(b.getX(), b.getY(), b.getX() + 3*(b.getX() - v.x), b.getY() + 3*(b.getY() - v.y));
    }
    textFont(font48);
    fill(128,128,128);
    text("push C to resume", width/2 - textWidth("push C to resume")/2, 64);
    text("push C to resume", width/2 - textWidth("push C to resume")/2, height - 32);
    noLoop();
    release();
  }
  
  public void addBall(Ball b) {
    balls.add(b);
  }
  public void addConnection(Ball b, FDistanceJoint j) {
    b.setParentMolecule(this);
    balls.add(b);
    connectors.add(j);
  }
  public void removeBall(Ball b) {
    balls.remove(b);
    for (Iterator<FDistanceJoint> i = connectors.iterator(); i.hasNext(); ) {
      FDistanceJoint j = i.next();
      if (j.getBody1() == b || j.getBody2() == b) {
        //j.removeFromWorld();
        i.remove();
      }
    }
  }
  public void merge(Molecule m, FDistanceJoint j) {
    if (this != m) {
      balls.addAll(m.getBalls());
      connectors.addAll(m.getConnectors());
      for (Ball b : m.getBalls()) {
        b.setParentMolecule(this);
      }
      m.release();
    }
    if (j != null) {
      connectors.add(j);
    }
  }
  
  public ArrayList<Ball> getBalls() {
    return balls;
  }
  public ArrayList<FDistanceJoint> getConnectors() {
    return connectors;
  }
  
  private PVector findCenter() {
    float x = 0;
    float y = 0;
    for (Ball b : balls) {
      x += b.getX();
      y += b.getY();
    }
    return new PVector(x / balls.size(), y / balls.size());
  }
  public void release() {
    connectors.clear();
    balls.clear();
  }
}
