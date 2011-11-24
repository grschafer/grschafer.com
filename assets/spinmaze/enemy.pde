class Enemy extends FCircle
{
  public Enemy(float circleSize)
  {
    super(circleSize);
  }
  public Enemy(float circleSize, float r, float g, float b, float restitution, float friction)
  {
    super(circleSize);
    this.setFill(r,g,b);
    this.setRestitution(restitution);
    this.setFriction(friction);
    this.setPosition(int(random(0,COLS)) * GAP + offsetX, int(random(0,ROWS)) * GAP + offsetY);
    this.setGrabbable(false);    // <-- THIS COULD PROVIDE INTERESTING OPPORTUNITIES
  }
}
