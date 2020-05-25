class SidePanelColours
{
  color panelBackgroundColour = color(50);
  color elementBackgroundColour = color(100);
  color highlightedColour = color(200);
  color textColour = color(255);
  color deemphasizedTextColour = color(175);
  
  color trueColour = color(0,255,0);
  color falseColour = color(255,0,0);
}
SidePanelColours spc = new SidePanelColours(); //This is done because things initialized with values from the "color" function cannot be made static.

class ExitComponent extends ControlPanelElement
{
  public static final int h = 20;

  protected WindowCoordinates position;
  
  @Override
  public void loopActions()
  {
    noStroke();
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.textColour);
    text("Exit", position.x+10, position.y+15);
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      exclusiveKeyboardInputUser = null;
      sidePanelStack.pop();
    }
  }
  
  public ExitComponent(WindowCoordinates position)
  {
    this.position = position;
  }
}
