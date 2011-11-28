class MyPathfinder extends Pathfinder
{
  public MyPathfinder()
  {
    super();
    this.corners = false;
    this.setCuboidNodes(COLS, ROWS, 1.0);
    for (int i = 0; i < this.nodes.size(); ++i)    // set all distances to a large number, initially
    {
      Node n = (Node)this.nodes.get(i);
      for (int j = 0; j < n.links.size(); ++j)
        ((Connector)n.links.get(j)).d = 1000;
    }
  }
}
