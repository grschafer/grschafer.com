class Orbiter extends Enemy
{
  private MazeNode[][] maze;
  public int nodeRow;
  public int nodeCol;
  public int targetNodeRow;
  public int targetNodeCol;
  public int direction;
  public boolean traveling;
  
  public Orbiter(float circleSize, float r, float g, float b, float restitution, float friction, MazeNode[][] m)
  {
    super(circleSize, r, g, b, restitution, friction);
    maze = m;
    traveling = false;
    direction = int(random(0,4));
    this.nodeRow = int(random(0,ROWS));
    this.nodeCol = int(random(0,COLS));
    this.setPosition(this.nodeCol * GAP + offsetX, this.nodeRow * GAP + offsetY);
    this.setRotation(direction * PI/2);
    this.setStatic(true);
  }
  public Orbiter(float circleSize, MazeNode[][] m)
  {
    super(circleSize);
    maze = m;
    traveling = false;
    direction = int(random(0,4));
    this.nodeRow = int(random(0,ROWS));
    this.nodeCol = int(random(0,COLS));
    this.setPosition(this.nodeCol * GAP + offsetX, this.nodeRow * GAP + offsetX);
    this.setRotation(direction * PI/2);
    this.setStatic(true);
  }
  public void determineTargetNode()
  {
    // check for walls
    if (maze[nodeRow][nodeCol].walls[(direction + 1) % 4] == 0)  // if wall to the right doesn't exist
      direction = (direction + 1) % 4;  // turn right
    else    // wall to the right does exist
    {
      if (maze[nodeRow][nodeCol].walls[direction] == 1)  // if wall in front exists
      {
        if (maze[nodeRow][nodeCol].walls[(direction + 3) % 4] == 1)  // if wall to the left exists also
          direction = (direction + 2) % 4;  // turn 180 degrees
        else
          direction = (direction + 3) % 4;  // turn left
      }
      // else direction remains the same
    }
    
    targetNodeRow = nodeRow + DY[direction];
    targetNodeCol = nodeCol + DX[direction];
    
    // if target node is outside maze then it's trying to leave the maze, so turn around (NEED BETTER)
    if (targetNodeRow < 0 || targetNodeRow >= ROWS || targetNodeCol < 0 || targetNodeCol >= COLS)
    {
      direction = (direction + 2) % 4;  // direct outwards
      determineTargetNode();
      return;
    }
    traveling = true;
  }
}
