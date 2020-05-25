import java.util.ArrayList;

class ControlPanel
{
  ArrayList<ControlPanelElement> elements;
  
  public ControlPanel()
  {
    elements = new ArrayList<ControlPanelElement>();
  }
  
  public void loopActions() //call in main loop
  {
      for(ControlPanelElement e : elements)
      {
        e.loopActions();
      }
  }
  
  public void mousePressedActions() //called once every time a mouse button is pressed; call in main mousePressed() handler
  {
    for(ControlPanelElement e : elements)
    {
      e.mousePressedActions();
    }
  }
  
  public void keyPressedActions() //call in keyPressed handler
  {
    for(ControlPanelElement e : elements)
    {
      e.keyPressedActions();
    }
  }
  
}

abstract class ControlPanelElement //This was left as an abstract class because at some point it may become necessary to put code here.
{
  
  //These methods are blank instead of abstract so that the extending class can override whichever ones need to be used instead of implementing empty methods for all of them that do not. 
  
  public void loopActions() //everything that happens in the loop, including redrawing the control
  {
    //This is left blank like the input handlers because some controls might not involve drawing or other loop actions at all.
  }
  
  public void mousePressedActions()
  {
    
  }
  
  public void keyPressedActions()
  {
    
  }
}

/*
  This class represents coordinates relative to the program window.
  It is important to distinguish between coordinate types because there will eventually be other coordinate systems, possibly including other systems used for positions on the screen. 
*/
class WindowCoordinates
{
  public int x;
  public int y;
  
  public WindowCoordinates(int x, int y)
  {
    this.x = x;
    this.y = y;
  }
}




// Classes unique to KerbalGIS
abstract class SidePanel extends ControlPanel
{
  @Override
  public void loopActions()
  {
    //Draw the side panel background to overwrite any newly inactive side panel elements and overflowing graphics from the viewport.
    noStroke();
    fill(spc.panelBackgroundColour);
    rect(0,0,sidePanelWidth, height);
    
    super.loopActions();
  }
  
  public void acceptGeoClick(GeographicCoordinates clickedCoordinates)
  {
    for(ControlPanelElement e: elements)
    {
      if(GeoClickAcceptor.class.isInstance(e)) //if e is a GeoClickAcceptor
      {
        ((GeoClickAcceptor)e).acceptGeoClick(clickedCoordinates);
      }
    }
  }
}

abstract class EditorPanel extends SidePanel
{
  Object[] editedObjectReference = null;
  List editedObjectDestination; //where the object will go when it is done; this may not be the main map element list
  
  abstract protected boolean editedObjectValid();
  
  @Override
  public void loopActions()
  {
    super.loopActions();
    
    if(editedObjectValid() && !editedObjectDestination.contains(editedObjectReference[0])) //when an object being newly created becomes valid
    {
      editedObjectDestination.add(editedObjectReference[0]);
      ((MapElement)editedObjectReference[0]).highlighted = true;
      viewport.needRedraw = true;
    }
  }
  
  protected boolean editingExistingObject()
  {
    return editedObjectReference[0] != null;
  }
  
  public void close()
  {
    if(editedObjectReference != null)
    {
      ((MapElement)editedObjectReference[0]).highlighted = false;
      viewport.needRedraw = true;
    }
  }
  
  public EditorPanel(Object[] editedObjectReference, List editedObjectDestination)
  {
    this.editedObjectReference = editedObjectReference;
    this.editedObjectDestination = editedObjectDestination;
    
    if(editingExistingObject())
    {
      ((MapElement)editedObjectReference[0]).highlighted = true;
      viewport.needRedraw = true;
    }
  }
}

abstract class GeoClickAcceptor extends ControlPanelElement
{
  abstract public void acceptGeoClick(GeographicCoordinates clickedCoordinates); //This is not implemented with an empty body because side panel element types not accepting geoclicks should not extend this class.
}
