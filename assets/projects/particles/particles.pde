import fisica.*;

// Stick and Ball Toy

/* ideas:

-make a Molecule class that is formed for any collection of Ball objects
Molecule can be responsible for dissolve (and add outward force to all Balls when dissolve does happen)
it is better than Ball.dissolved
Ball can keep track of parent Molecule, instead of tracking all connectors and connections
ProximityMonitor still needs balls, but does it need connectors?

-FIGURE OUT WHAT THE COLORS SHOULD DO
-have more interesting interactions
-chain reactions if there's enough diff kinds of balls there?

-fission/fusion

-allow balls of different sizes (connection distance varies with ball size?)
-add static terrain? (randomized?)
  -"magnetic" fields?
-some kind of objective/goal?

-the joints are taking energy out of the system by not being completely rigid

*/

public final color COLOR_BLUE = color(0,0,255);
public final color COLOR_GREEN = color(0,255,0);
public final color COLOR_RED = color(255,0,0);
public final color COLOR_PURPLE = color(255,0,255);

public static final int NUM_BALLS = 10;
public static final int BALL_SIZE_MIN = 10;
public static final int BALL_SIZE_MAX = 50;
public static final float CONNECTION_DISTANCE = 0;  // this is added to ball diameter to determine at what distance to connect
public static final float DISSOLVE_DISTANCE = 0;    // similarly, this is added to ball diameter for dissolving

public static final int[] COLORS = {Ball.BLUE, Ball.GREEN, Ball.RED, Ball.PURPLE};
//public static final int[] COLORS = {Ball.BLUE, Ball.BLUE, Ball.BLUE, Ball.BLUE};

public ProximityMonitor proxMon;
public FWorld world;
public FCircle c;
public PFont font16, font48;
public boolean debugMode = false;

void setup() {
  frameRate(60);
  size(640,640, JAVA2D);  // java2d or p2d?
  smooth();
  //colorMode(HSB,360,100,100);
  background(255);
  
  font16 = loadFont("ArialMT-16.vlw");
  font48 = loadFont("ArialMT-48.vlw");
  
  
  Fisica.init(this);
  world = new FWorld();
  proxMon = new ProximityMonitor(world);
  
  world.setEdges(0,0, width, height, color(200));
  world.setEdgesFriction(0);
  world.setEdgesRestitution(1.0);
  world.setGravity(0,0);
  
  for (int i = 0; i < NUM_BALLS; i++) {
    Ball b = new Ball(random(BALL_SIZE_MIN, BALL_SIZE_MAX), COLORS[int(random(0,4))]);
    b.setPosition(random(40, width-40), random(40, height-40));
    proxMon.add(b);
    world.add(b);
  }
}

void draw() {
  background(255);
  
  // easy speed-up hack (but makes fusion finicky)
  //if (frameCount % 2 == 0) {
    proxMon.monitor();
  //}
  
  textFont(font16);
  fill(128,128,128);
  text("push R to reset", 16, height-16);
  world.step();
  world.draw();
}

void keyPressed() {
  switch (key) {
    case 'r':
      println("reset");
      setup();
      break;
    case '`':  // toggle debug mode
      debugMode = (debugMode ? false : true);  break;
    case 'c':
      loop();
      break;
  }
}
