/*
 * Used by the Kruskal's maze generation algorithm
 *
 */

class MazeEdge
{
  public int row;
  public int col;
  public int dir;  // will be 0 (north) or 3 (west)
  
  public MazeEdge(int row, int col, int dir)
  {
    this.row = row;
    this.col = col;
    this.dir = dir;
  }
}
