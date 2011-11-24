class MazeNode
{
  // [0] = north wall
  // [1] = east wall
  // [2] = south wall
  // [3] = west wall
  public int walls[] = {1,1,1,1};
  public boolean visited;
  
  public MazeNode()
  {
    visited = false;
  }
  public String toString()
  {
    return "[" + walls[0] + " " + walls[1] + " " + walls[2] + " " + walls[3] + "]";
  }
}
