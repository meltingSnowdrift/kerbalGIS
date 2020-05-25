
class ElementListPanel extends SidePanel
{
  private void refreshElementList()
  {
    elements = new ArrayList<ControlPanelElement>(); //Clear the element list each time because the map element list may have been changed.
    
    int nextY = 0;
    for(MapElement e: mapElementList)
    {
      elements.add(new ElementListing(new WindowCoordinates(1,nextY), e));
      nextY+=ElementListing.h+1;
    }
    
    elements.add(new ElementCreationButton(new WindowCoordinates(1, nextY)));
  }
  
  @Override
  public void loopActions()
  {
    super.loopActions(); //This is called because the loop action call still needs to be relayed to all the elements as usual. 
    
    refreshElementList(); //Do this once every frame; if this is unacceptable for performance, find some way to only do it when the map element list changes.
  }
}

class ElementListing extends ControlPanelElement
{
  public static final int h = 35;
  
  private WindowCoordinates position;
  private MapElement representedElement;
  
  @Override
  public void loopActions()
  {
    noStroke();
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.textColour);
    text(representedElement.displayName, position.x+25, position.y+15);
    fill(spc.deemphasizedTextColour);
    text(representedElement.elementTypeDisplayName, position.x+25, position.y+30);
    
    if(representedElement.shown)
    {
      fill(spc.trueColour);
    }
    else
    {
      fill(spc.falseColour);
    }
    rect(position.x+3, position.y+3, 10, h-6);
  }
  
  @Override
  public void mousePressedActions()
  {
    //If the click falls within the visibility button 
    if(mouseX > position.x+3 && mouseX < position.x+3+10 && mouseY > position.y+3 && mouseY < position.y + (h-6))
    {
      representedElement.shown = !representedElement.shown;
      viewport.needRedraw = true; //Force a viewport redraw because the visibility of something has been changed.
      //println(viewport.needRedraw);
      
      return;
    }
    
    //If a click falls within the listing and did not match the other conditions
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h)
    {
      if(representedElement.editorPanel != null)
      {
        MapElement[] editedElementReference = new MapElement[1];
        editedElementReference[0] = representedElement;
        try
        {
          //Add an editor appropriate to the edited element's class to the side panel stack.
          //Apparently, the constructor involved in this process has an undeclared first argument which expects a pointer to the PApplet.
          sidePanelStack.push((EditorPanel)representedElement.editorPanel.getConstructors()[0].newInstance(appletReference,(Object)editedElementReference, mapElementList));
        }
        catch(Exception e)
        {
          println("Mooooooooo!!!");
          e.printStackTrace();
        }
      }
      else
      {
        println("This element has no associated editor.");
      }
      
      return;
    }
  }
  
  public ElementListing(WindowCoordinates wc, MapElement e)
  {
    position = wc;
    representedElement = e;
  }
}

class ElementCreationButton extends ControlPanelElement
{
  public static final int h = 20;

  private WindowCoordinates position;
  
  @Override
  public void loopActions()
  {
    noStroke();
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.textColour);
    text("Create", position.x+10, position.y+15);
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      sidePanelStack.push(new ElementCreationPanel());
    }
  }
  
  public ElementCreationButton(WindowCoordinates position)
  {
    this.position = position;
  }
}
