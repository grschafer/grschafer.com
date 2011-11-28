/*
 * Credit for algorithm implementation:
 * http://weblog.jamisbuck.org/2011/2/7/maze-generation-algorithm-recap
 * 
 * Other maze info:
 * http://www.astrolog.org/labyrnth/algrithm.htm
 */

class MazeGenerator
{
  /* accept nodes[][] in constructor
    then a method will be called and that
    maze generation algorithm will be performed
    on nodes[][] */
  
  public MyPathfinder dijk;
  private static final int NUM_MAZES_AVAILABLE = 3;
  private MazeNode nodes[][];
  private int endRow;
  private int endCol;
  
  public MazeGenerator(MazeNode nodes[][])
  {
    this.nodes = nodes;
    dijk = new MyPathfinder();
  }
  public void genMaze(int mazeType)
  {
    if (mazeType == 0)
      mazeType = int(random(0, NUM_MAZES_AVAILABLE) + 1);
    println("mazetype=" + mazeType);
    switch (mazeType)
    {
      case 1:
        genMazeRecursiveBacktrack(int(ROWS/2), int(COLS/2));  break;
      case 2:
        genMazeBinaryTree();  break;
      case 3:
        genMazeKruskal();  break;
      default:
        genMazeRecursiveBacktrack(int(ROWS/2), int(COLS/2));  break;
    }
    makeRandomEndSpot();
  }
  public void genMazeRecursiveBacktrack(int row, int col)
  {
    nodes[row][col].visited = true;
    int directions[] = genRandDirections();
    
    for (int i = 0; i < directions.length; ++i)
    {
      int dir = directions[i];
      int newRow = row + DY[dir];
      int newCol = col + DX[dir];
      if (newCol >= 0 && newCol < COLS && newRow >= 0 && newRow < ROWS && !nodes[newRow][newCol].visited)
      {
        nodes[row][col].walls[dir] = 0;
        nodes[newRow][newCol].walls[opp(dir)] = 0;
        ((Node)dijk.nodes.get(row * COLS + col)).setDistBoth((Node)dijk.nodes.get(newRow * COLS + newCol), 1);
        genMazeRecursiveBacktrack(newRow, newCol);
      }
    }
  }
  public void genMazeBinaryTree()
  {
    Vector<Integer> directions = new Vector<Integer>();
    for (int row = 0; row < ROWS; ++row)
    {
      for (int col = 0; col < COLS; ++col)
      {
        directions.clear();
        // algorithm goes north or west, by default
        if (row > 0)
          directions.add(0);
        if (col > 0)
          directions.add(3);
        
        if (directions.size() > 0)
        {
          int dir = directions.get(floor(random(directions.size())));
          int newRow = row + DY[dir];
          int newCol = col + DX[dir];
          nodes[row][col].walls[dir] = 0;
          nodes[newRow][newCol].walls[opp(dir)] = 0;
          ((Node)dijk.nodes.get(row * COLS + col)).setDistBoth((Node)dijk.nodes.get(newRow * COLS + newCol), 1);
        }
      }
    }
  }
  
  public void genMazeKruskal()
  {
    ArrayList<MazeEdge> edges = new ArrayList<MazeEdge>();
    int[][] sets = new int[ROWS][COLS];
    
    for (int row = 0; row < ROWS; ++row)
    {
      for (int col = 0; col < COLS; ++col)
      {
        sets[row][col] = row * COLS + col; // every node is part of a (unique) set
        
        if (row > 0)
          edges.add(new MazeEdge(row, col, 0));  // add edge from this node directed north
        if (col > 0)
          edges.add(new MazeEdge(row, col, 3));  // add edge from this node directed west
      }
    }
    Collections.shuffle(edges);  // randomize edge-picking order
    println("number of edges = " + edges.size());
    
    while (!edges.isEmpty())
    {
      MazeEdge e = edges.remove(0);
      int row = e.row;
      int col = e.col;
      int dir = e.dir;
      int newRow = row + DY[dir];
      int newCol = col + DX[dir];
      if (sets[row][col] != sets[newRow][newCol])
      {
        nodes[row][col].walls[dir] = 0;
        nodes[newRow][newCol].walls[opp(dir)] = 0;
        ((Node)dijk.nodes.get(row * COLS + col)).setDistBoth((Node)dijk.nodes.get(newRow * COLS + newCol), 1);
        
        // update all set numbers
        int newSetNum = sets[row][col];
        int oldSetNum = sets[newRow][newCol];
        for (int i = 0; i < ROWS; ++i)
        {
          for (int j = 0; j < COLS; ++j)
          {
            if (sets[i][j] == oldSetNum)
            {
              sets[i][j] = newSetNum;
            }
          }
        }
      }
    }
  }
  
  public void makeRandomEndSpot()  // belongs to board or maze generator?
  {
    int numSides = 2*(ROWS + COLS);
    int spot = int(random(0,numSides));
    //println("spot=" + spot);
    
    int row = 0, col = 0;
    if (spot < COLS)  // top of maze
    {
      row = 0;
      col = spot;
      nodes[row][col].walls[0] = 0;
    }
    else if (spot >= numSides - COLS)  // bottom of maze
    {
      row = ROWS - 1;
      col = spot - (numSides - COLS);
      nodes[row][col].walls[2] = 0;
    }
    else if (spot >= COLS)  // side of maze
    {
      row = int((spot - COLS) / 2);
      if ((spot - COLS) % 2 == 0)      // left side
      {
        col = 0;
        nodes[row][col].walls[3] = 0;
      }
      else  // (spot - COL) % 2 == 1  // right side
      {
        col = COLS - 1;
        nodes[row][col].walls[1] = 0;
      }
    }
    endRow = row;
    endCol = col;
  }
  
  public ArrayList<Node> getShortestPath()
  {
    return dijk.aStar((Node)dijk.nodes.get(int(ROWS/2) * COLS + int(COLS/2)), (Node)dijk.nodes.get(endRow * COLS + endCol));
  }
  
  public float getShortestDist()
  {
    // add dijkstra's here to make sure of shortest path
    float shortestDist = 0;
    path = dijk.aStar((Node)dijk.nodes.get(int(ROWS/2) * COLS + int(COLS/2)), (Node)dijk.nodes.get(endRow * COLS + endCol));
    for (Node n : path)
    {
      if (n.parent != null)
      {
        shortestDist += ((Connector)n.links.get(n.indexOf(n.parent))).d;
      }
    }
    return shortestDist * GAP;
  }

  // used by maze gen algorithms
  private int opp(int dir)
  {
    return (dir + 2) % 4;
  }
  // used by recursive backtrack
  private int[] genRandDirections()
  {
    int dirs[] = {0,1,2,3};
    for (int i = dirs.length - 1; i > 0; --i)
    {
      int rand = floor(random(0,i+1));
      int temp = dirs[i];
      dirs[i] = dirs[rand];
      dirs[rand] = temp;
      
    }
    return dirs;
  }
}
