
class ElementCreationPanel extends SidePanel
{
  MapElement[] createdElementReference = {null};
  
  private void populateElementList()
  {
    //This has to be done manually because it appears to be quite hard to automate the associations involved without instantiating the involved classes.
    int nextY = 1;
    elements.add(new ElementTypeListing(new WindowCoordinates(1, nextY), PointMarkerEditorPanel.class, "Point marker", createdElementReference));
    nextY += ElementTypeListing.h + 1;
    elements.add(new ElementTypeListing(new WindowCoordinates(1, nextY), FilledCircleEditorPanel.class, "Filled circle", createdElementReference));
    nextY += ElementTypeListing.h + 1;
    elements.add(new ElementTypeListing(new WindowCoordinates(1, nextY), GreatCircleSegmentEditorPanel.class, "Great circle segment", createdElementReference));
    nextY += ElementTypeListing.h + 1;
    
    elements.add(new ExitComponent(new WindowCoordinates(1, nextY)));
  }
  
  @Override
  public void loopActions()
  {
    super.loopActions();
    
    if(createdElementReference[0] !=null && sidePanelStack.peek() == this) //If something valid has been created from this panel and control has fallen back to it from the editor 
    {
      if(mapElementList.contains(createdElementReference[0])) //if the editor panel was not exited by deleting the new element
      {
        sidePanelStack.pop(); //remove this panel from the stack
      }
      else
      {
        //Reset things for another attempt.
        createdElementReference[0] = null;
      }
    }
  }
  
  public ElementCreationPanel()
  {
    populateElementList();
  }
}

class ElementTypeListing extends ControlPanelElement
{
  Class editorPanelClass;
  String label;
  MapElement[] createdElementReference;
  
  WindowCoordinates position;
  
  public static final int h = 20;

  @Override
  public void loopActions()
  {
    noStroke();
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.textColour);
    text(label, position.x+10, position.y+15);
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      try
      {
        //println(editorPanelClass.getConstructors()); //debug
        sidePanelStack.push((SidePanel)editorPanelClass.getConstructors()[0].newInstance(appletReference, createdElementReference, mapElementList));
      }
      catch(Exception e)
      {
        println("Meeeeeooooowwwww!!!");
        e.printStackTrace();
      }
    }
  }
  
  public ElementTypeListing(WindowCoordinates position, Class editorPanelClass, String label, MapElement[] createdElementReference)
  {
    this.position = position;
    this.editorPanelClass = editorPanelClass;
    this.label = label;
    this.createdElementReference = createdElementReference;
  }
}
