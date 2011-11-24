class Player extends FCircle
{
  public Player(float circleSize)
  {
    super(circleSize);
    //this.setBullet(true);
    this.setGrabbable(false);
  }
  public void setPhysics(int setting)
  {
    switch (setting)
    {
      //case 1:  // this is the default
      case 2:
        this.setFill(255,0,255);
        this.setRestitution(1);
        this.setFriction(1);
        break;
      case 3:
        this.setFill(160,160,255);
        this.setRestitution(0);
        this.setFriction(0);
        break;
      case 4:
        this.setFill(0,160,0);
        this.setRestitution(0.5);
        this.setFriction(0.5);
        break;
      default:
        this.setFill(255);
        this.setRestitution(0);
        this.setFriction(1);
    }
  }
}
