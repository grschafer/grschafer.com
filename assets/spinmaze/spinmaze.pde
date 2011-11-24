import controlP5.*;
import ai.pathfinder.*;
import fisica.*;


/**
 * Rotating Maze with Ball
 *
 * Greg Schafer
 */


/*
DONE:
  -give the user control over world rotation (damp movement? how much?)
  -make sure the maze is "good" (actually maze-like and possible to solve...use A*?)
    -if shortest path doesn't exist or is too short, regen the level
    -instead of current A* implementation, use Dijkstra's to gen paths to any exterior node (check node.g for all of them and take the smallest as the shortestDist)
    -use an actual maze generation algorithm instead of hoping randomness connects
      -http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
  -separate maze size (spacing and # of cells) from applet width and height
  -victory detection (when ball falls off screen-bottom or intersects with sensor at final position)
    -escape maze or somewhere in maze?
  -scoring (time, lives, ?)
    -use dijkstra and compare distance traveled by the ball with calculated shortest distance
    -also have a timer (but what to compare it to since the mazes are random?)
  -add a debug mode (push "~") to show shortest path, AI pathing, and other interesting lines/drawing
  -make different ball types available (diff size, restitution, friction, ?)
  -mouse being in wrong spot (coming off GUI or starting a new maze) is pretty annoying...give user countdown to get mouse to correct spot?)
    -gray out the screen and pause game--have a highlighted circle over where the maze angle is...when cursor enters the circle, play resumes
      -do this for exiting applet, losing focus, entering UI bar, hitting ctrl?

TODO:
    -shortest distance is flawed because of cutting corners (make dijkstra's corner-connected?)
  -make different maze types available (different properties like solution %, multiple paths)
    -http://weblog.jamisbuck.org/2010/12/29/maze-generation-eller-s-algorithm
    -http://www.ccs.neu.edu/home/snuffy/maze/
    -PUT ALL MAZE GENERATION ALGORITHMS IN A DIFFERENT CLASS (PASS nodes[][] to constructor)
  -ensure that the player has a chance (doesn't spawn in or directly above a ball, has a side entrance before nearest enemy, etc.)
  -monsters/traps in the maze? (* = done)
    -*red ball that rolls around (based on how the user rotates maze)...touching = death
    -*blue ball that follows right-hand rule through maze (unaffected by physics/rotation)...touching = death
    -conveyor squares, physical elevators, bounce pads, frictionless walls, bouncy walls, timed buttons, removable walls (ie get blue key to remove blue walls), etc
    -for chasing enemies, need multiple paths or some other avoidance mechanic?
      -multiple paths = booby trap squares or monsters that orbit an inner set of walls
  -level editor (separate application)
    -textual level format that can be copy-pasted between apps
    -start with full maze or something generated with one of the algorithms...then user left/right click-drags through grid spots to make/remove walls
    -palette of entities/objects that can be placed on the grid
*/


public FWorld world;
public ControlP5 controlP5;
public RadioButton radioBtn;
public Board board;
public MazeGenerator mazegen;

public MazeNode[][] nodes;
public ArrayList<Node> path;
public ArrayList<FBody> rotateUs;
public ArrayList<Enemy> enemies;
public ArrayList<Orbiter> orbiters;

public Player player;
public float ballDist;
public float ballLastDist;
public float totalDist;
public float startTime;
public float totalTime;

public float mazeAng;
public float mouseAng;


public int offsetX = 0;
public int offsetY = 0;

public PFont font48;
public PFont font36;
public int atEndScreen = 0;  // 0 = false, 1 = victory screen, 2 = defeat screen
public int mazeType = 0;
public boolean debugMode = false;
public boolean gamePaused = false;
public boolean cursorLeftUnpauseCircle = true;
// constants
public static final int UI_BAR_HEIGHT = 40;
public static final float ROT_SPEED = 0.05;  // this can be turned up, because the ball is in rotateUs
public static final float BALL_DIAM = 5;
public static final int DX[] = {0,1,0,-1};
public static final int DY[] = {-1,0,1,0};
public static final String RANDOM = "Random";
public static final String RECURSIVE_BACKTRACK = "Recursive Backtrack";
public static final String BINARY_TREE = "Binary Tree";
public static final String KRUSKAL = "Kruskal";

public int NUM_ROLLERS = 2;
public int NUM_ORBITERS = 1;
// stupid hack so changing maze settings in the UI doesn't frak up code (eg - orbiters) that use those settings
public int ROWS = 12;
public int COLS = 12;
public int GAP = 40;
public int rows = ROWS;
public int cols = COLS;
public int gap = GAP;

void setup()
{
  frameRate(60);
  size(640,640);
  //size(640,640,P2D);  // causes walls to be invisible...?
  smooth();
  
  initGUI();  // CALLING THIS MULTIPLE TIMES (BY RESETTING) MAKES THE BANG CLICK LOTS?
  
  hint(ENABLE_NATIVE_FONTS);
  font48 = loadFont("ArialMT-48.vlw");
  font36 = loadFont("ArialMT-36.vlw");
  //textMode(SCREEN);
  
  
  // physics stuff
  Fisica.init(this);
  world = new FWorld();
  
  reset();
}

public void reset()
{
  // stupid hack so changing maze settings in the UI doesn't frak up code (eg - orbiters) that use those settings
  ROWS = rows;
  COLS = cols;
  GAP = gap;
  // end stupid hack
  // offset values describe blank space between applet edges and the edges of the maze
  offsetX = (width - COLS*GAP)/2 + GAP/2;
  offsetY = (height - ROWS*GAP)/2 + GAP/2;
  mazeAng = 0.0;
  mouseAng = 0.0;
  
  atEndScreen = 0;
  cursorLeftUnpauseCircle = true;
  if (mag(mouseX - (width/2 + width/4 * cos(mazeAng)), mouseY - (height/2 - height/4 * sin(mazeAng))) > 50)
    gamePaused = true;
  else
    gamePaused = false;
  
  
  // declare and initialize field of maze nodes/tiles
  nodes = new MazeNode[ROWS][COLS];
  for (int x = 0; x < ROWS; ++x)
    for (int y = 0; y < COLS; ++y)
      nodes[x][y] = new MazeNode();
      
  // generate the maze (the maze will be stored in nodes)
  mazegen = new MazeGenerator(nodes);
  mazegen.genMaze(mazeType);
  path = mazegen.getShortestPath();
  println("shortest distance: " + mazegen.getShortestDist());
  
  world.clear();
  
  rotateUs = new ArrayList<FBody>();
  board = new Board(nodes);
  board.initTerrain();
  
  player = new Player(GAP/2);
  player.setPosition(COLS/2 * GAP + offsetX, ROWS/2 * GAP + offsetY);
  rotateUs.add(player);
  world.add(player);
  
  // add enemies
  enemies = new ArrayList<Enemy>();
  // add roller enemies
  for (int i = 0; i < NUM_ROLLERS; ++i)
  {
    enemies.add(new Enemy(GAP/2 + random(-GAP/4, GAP/4),255,0,0,0,1));
    enemies.get(i).setRotation(random(-PI, PI));
    rotateUs.add(enemies.get(i));
    world.add(enemies.get(i));
  }
  
  // add orbiter enemies
  orbiters = new ArrayList<Orbiter>();
  for (int i = 0; i < NUM_ORBITERS; ++i)
  {
    orbiters.add(new Orbiter(GAP/2,128,128,255,0,1, nodes));
    enemies.add(orbiters.get(i));
    rotateUs.add(orbiters.get(i));
    world.add(orbiters.get(i));
  }
  
  radioBtn.activate(0);
  // reset scoring mechanisms (distance and time)
  ballLastDist = dist(player.getX(), player.getY(), rotateUs.get(0).getX(), rotateUs.get(0).getY());
  ballDist = 0;
  startTime = millis();
}


void draw()  // break out into more functions?
{
  if (!focused)  // applet lost focus
    gamePaused = true;
  if (!gamePaused)
    background(255);
  else  // if game paused, shade out background and draw unpausing circle
  {
    background(180);
    stroke(0);
    fill(255);
    ellipse(width/2 + width/4 * cos(mazeAng), height/2 - height/4 * sin(mazeAng),100,100);
  }
  
  // debug drawing (draws dot grid and shortest path)
  if (debugMode)
    debugDraw();
  
  stroke(0);
  // measures distance traveled by player relative to the maze
  if (frameCount % 10 == 0)
  {
    ballDist += abs(dist(player.getX(), player.getY(), rotateUs.get(0).getX(), rotateUs.get(0).getY()) - ballLastDist);
    ballLastDist = dist(player.getX(), player.getY(), rotateUs.get(0).getX(), rotateUs.get(0).getY());
  }
  // end of measuring distance traveled by player
  
  // physics hack: prevents bodies from warping through walls when they go to rest
  if (player.isResting())
    player.addForce(0,0.1);
  for (FBody e : enemies)
    if (e.isResting())
      e.addForce(0,0.1);
  // end of physics hack
  
  
  world.draw();
  if (!gamePaused)
  {
    // calculate angle and rotate maze
    float diffAng = mazeAng - mouseAng;
    // angle adjustments for crossing the 180-degree line
    if (abs(mazeAng - mouseAng + 2*PI) < abs(diffAng))
      diffAng = mazeAng - mouseAng + 2*PI;
    if (abs(mazeAng - mouseAng - 2*PI) < abs(diffAng))
      diffAng = mazeAng - mouseAng - 2*PI;
    board.rotateTerrain(ROT_SPEED*diffAng);
    // end of angle calculation and maze rotation
    
    // draw difference between maze angle and mouse angle
    float colorScale = abs(diffAng) * 255 / PI;
    fill(colorScale, 0, 255 - colorScale, 60);
    arc(width/2, height/2, width/2, height/2, -mazeAng, -mazeAng + diffAng);
    arc(width/2, height/2, width/2, height/2, -mazeAng + diffAng, -mazeAng);
    // end of draw difference between maze angle and mouse angle
    
    // game loops
    moveEnemies();  // move active enemies
    checkVictory();  // checks victory condition (and restarts game)
    
    // fisica functions for drawing and simulating world physics
    world.step();
  }
  
  // end screen should be drawn atop game objects
  if (atEndScreen != 0)
    drawEndScreen();
  
  // UI bar must be drawn on top, so it's at the bottom
  noStroke();
  fill(0,80);
  rect(0,0, width,UI_BAR_HEIGHT);
  
  // needed if using P2D
  //controlP5.draw();
}

public void moveEnemies()  // package in enemies class?
{
  for (Orbiter f : orbiters)
  {
    if (!f.traveling)  // if not traveling
      f.determineTargetNode();  // pick target
    else  // go towards target
    {
      PVector transX = new PVector(cos(mazeAng), sin(mazeAng));
      PVector transY = new PVector(-sin(mazeAng), cos(mazeAng));
      PVector v = new PVector(f.targetNodeCol * GAP - width/2 + offsetX, f.targetNodeRow * GAP - height/2 + offsetY);
      float px = v.dot(transX) + width/2;
      float py = v.dot(transY) + height/2;
      float angle = atan2(py - f.getY(), px - f.getX());
      float moveSpeed = 1.0;
      stroke(255,0,0);
      line(f.getX(), f.getY(), px, py);
      f.setRotation(angle);
      f.adjustPosition(moveSpeed * cos(angle), moveSpeed * sin(angle));
      if (dist(f.getX(), f.getY(), px, py) < 1)  //  if at target
      {
        f.nodeRow = f.targetNodeRow;
        f.nodeCol = f.targetNodeCol;
        f.traveling = false;  //  set not traveling
      }
    }
  }
}

public void drawEndScreen()  // package in GUI class?
{
  if (atEndScreen == 1)    // victory
  {
    int distance = int(totalDist);
    
    fill(255,90);
    rect(64,64, width - 128, height - 128);
    fill(0);
    textFont(font48);
    text("Victory!", width/2 - textWidth("Victory!")/2, height/2 - 64);
    textFont(font36);
    text("Distance traveled: " + distance, width/2 - textWidth("Distance traveled: " + distance)/2, height/2);
    text("Time taken: " + totalTime + " s.", width/2 - textWidth("Time taken: " + totalTime + " s.")/2, height/2 + 64);
    fill(64);
    text("Click to restart", width/2 - textWidth("Click to restart")/2, height/2 + 128);
  }
  else if (atEndScreen == 2)  // defeat
  {
    fill(255,80);
    rect(64,64, width - 128, height - 128);
    fill(0);
    textFont(font48);
    text("Defeat!", width/2 - textWidth("Defeat!")/2, height/2 - 64);
    fill(64);
    textFont(font36);
    text("Click to restart", width/2 - textWidth("Click to restart")/2, height/2);
  }
}

public void checkVictory()
{
  // have a physics sensor at the end spot to use as the victory condition?
  if (player.getY() > height + 100 && atEndScreen == 0)
  {
    atEndScreen = 1;
    totalDist = ballDist;
    totalTime = (millis() - startTime) / 1000;
    // ballDist is not directly comparable to shortestDist because ballDist records distance falling offscreen
    println("VICTORY!");
    println("Distance traveled: " + ballDist);
    println("Time taken: " + totalTime);
  }
}

void contactStarted(FContact contact)
{
  if (contact.getBody1() == player || contact.getBody2() == player)
    if (enemies.contains(contact.getBody1()) || enemies.contains(contact.getBody2()))
      atEndScreen = 2;
}
void mousePressed()    // exits finish screen
{
  if (atEndScreen != 0)
    reset();
}

void keyPressed()
{
  switch (key)
  {
    case 'r':  // reset
    case 'R':
      reset();  break;
    case '`':  // toggle debug mode
      debugMode = (debugMode ? false : true);  break;
    // 1-4 = player physics settings
    case '1':
      radioBtn.activate("1");  break;
    case '2':
      radioBtn.activate("2");  break;
    case '3':
      radioBtn.activate("3");  break;
    case '4':
      radioBtn.activate("4");  break;
    case CODED:
      if (keyCode == CONTROL)
        gamePaused = true;
        if (mag(mouseX - (width/2 + width/4 * cos(mazeAng)), mouseY - (height/2 - height/4 * sin(mazeAng))) < 50)
          cursorLeftUnpauseCircle = false;
      break;
  }
}
void mouseMoved()
{
  // if mouse is over the UI bar, pause game
  if (mouseY < UI_BAR_HEIGHT)
    gamePaused = true;
  if (!gamePaused)  // if game isn't paused rotate maze as normal
    mouseAng = atan2(-(mouseY - height/2), mouseX - width/2);
  else  // if game is paused, don't unpause until mouse moves back into highlighted circle
  {
    if (cursorLeftUnpauseCircle && mag(mouseX - (width/2 + width/4 * cos(mazeAng)), mouseY - (height/2 - height/4 * sin(mazeAng))) < 50)
      gamePaused = false;
    else if (!cursorLeftUnpauseCircle && mag(mouseX - (width/2 + width/4 * cos(mazeAng)), mouseY - (height/2 - height/4 * sin(mazeAng))) > 50)
      cursorLeftUnpauseCircle = true;
  }
}

public void debugDraw()
{
  stroke(0,255,0);
  line(rotateUs.get(0).getX(), rotateUs.get(0).getY(), player.getX(), player.getY());  // draws reference line
  // draws the grid of dots
  stroke(0);
  PVector transX = new PVector(cos(mazeAng), sin(mazeAng));
  PVector transY = new PVector(-sin(mazeAng), cos(mazeAng));
  for (int i = 0; i < ROWS; ++i)
  {
    for (int j = 0; j < COLS; ++j)
    {
      PVector v = new PVector(j * GAP - width/2 + offsetX, i * GAP - height/2 + offsetY);
      point(v.dot(transX) + width/2, v.dot(transY) + height/2);
    }
  }
  // end of drawing grid of dots
  
  // draws shortest path (doesn't rotate)
  for (Node n : path)  // draw shortest path
  {
    if (n.parent != null)
    {
      stroke(255,0,255);
      strokeWeight(2);
      PVector v1 = new PVector(n.x * GAP - width/2 + offsetX, n.y * GAP - height/2 + offsetY);
      PVector v2 = new PVector(n.parent.x * GAP - width/2 + offsetX, n.parent.y * GAP - height/2 + offsetY);
      line(v1.dot(transX) + width/2, v1.dot(transY) + height/2, v2.dot(transX) + width/2, v2.dot(transY) + height/2);
    }
  }
  // end of drawing shortest path
}

public void initGUI()
{
  // controls for # rows, # cols, tile/gap size
  controlP5 = new ControlP5(this);
  controlP5.addSlider("rows", 1, 40, rows, 4, 2, 60, 12);
  controlP5.addSlider("cols", 1, 40, cols, 4, 14, 60, 12);
  controlP5.addSlider("gap", 10, 50, gap, 4, 26, 60, 12);
  controlP5.addBang("reset", 130, 20, 52, 16).captionLabel().style().moveMargin(-16, 0, 0, 14);  // BANG = BAD IDEA? it repeatedly resets, the more you push it
  // controls for type of maze to generate (dropdown)
  DropdownList mazeList = controlP5.addDropdownList("maze type", 120, 13, 100, 120);
  mazeList.addItem(RANDOM, 0);
  mazeList.addItem(RECURSIVE_BACKTRACK, 1);
  mazeList.addItem(BINARY_TREE, 2);
  mazeList.addItem(KRUSKAL, 3);
  // kruskal's, prim's, growing tree?
  // controls for fc (size, restitution, friction, color?)
  controlP5.addTextlabel("phys_label", "Physics", 258, 3);
  radioBtn = controlP5.addRadioButton("radioButton",260,14);
  radioBtn.setItemsPerRow(2);
  radioBtn.addItem("1", 1).captionLabel().style().moveMargin(0,0,0,-23);
  radioBtn.addItem("2", 2).captionLabel();
  radioBtn.addItem("3", 3).captionLabel().style().moveMargin(0,0,0,-23);
  radioBtn.addItem("4", 4).captionLabel();
  //radioBtn.getItem(0).setState(true);
  // controls for number and type of enemies (checkbox and slider)
  controlP5.addSlider("NUM_ROLLERS", 0, 20, NUM_ROLLERS, 340, 2, 60, 16);
  controlP5.addSlider("NUM_ORBITERS", 0, 10, NUM_ORBITERS, 340, 22, 60, 16);
}
void controlEvent(ControlEvent theEvent)
{
  if (theEvent.isGroup())
  {
    //println(theEvent.group().captionLabel());
    if (theEvent.group().captionLabel().getText().equals(RANDOM))
      mazeType = 0;
    else if (theEvent.group().captionLabel().getText().equals(RECURSIVE_BACKTRACK))
      mazeType = 1;
    else if (theEvent.group().captionLabel().getText().equals(BINARY_TREE))
      mazeType = 2;
    else if (theEvent.group().captionLabel().getText().equals(KRUSKAL))
      mazeType = 3;
    else if (theEvent.group().name().equals("radioButton"))
      player.setPhysics(int(theEvent.group().value()));
  }
}
