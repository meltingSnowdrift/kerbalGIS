import java.util.function.*;


class CoordinatesEditorComponent extends GeoClickAcceptor
{
  private GeographicCoordinates editedCoordinates;
  private String labelText;
  private boolean clickAcceptanceActive = false;
  
  public static final int h = 35;

  private WindowCoordinates position;
  
  @Override
  public void loopActions()
  {
    if(clickAcceptanceActive)
    {
      stroke(spc.highlightedColour);
    }
    else
    {
      noStroke();
    }
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    noStroke();
    fill(spc.deemphasizedTextColour);
    text(labelText, position.x+10, position.y+15);
    
    noStroke();
    fill(spc.textColour);
    if(editedCoordinates != null)
    {
      text(editedCoordinates.toString(), position.x+20, position.y+30);
    }
    else
    {
      text("none", position.x+20, position.y+30);
    }
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      clickAcceptanceActive = !clickAcceptanceActive; 
    }
  }
  
  @Override
  public void acceptGeoClick(GeographicCoordinates clickedCoordinates)
  {
    if(clickAcceptanceActive)
    {
      //Because editedCoordinates is a reference to something elsewhere, direct modification of its members is necessary instead of pointing it to a new instance.
      editedCoordinates.longitude = clickedCoordinates.longitude;
      editedCoordinates.latitude = clickedCoordinates.latitude;
      
      viewport.needRedraw = true;
      
      clickAcceptanceActive = false;
    }
  }
  
  public CoordinatesEditorComponent(WindowCoordinates wc, GeographicCoordinates editedCoordinates, String labelText) //This component is attached to some particular coordinates on initialization. 
  {
    this.position = wc;
    this.editedCoordinates = editedCoordinates;
    this.labelText = labelText;
  }
}

class NametagEditorComponent extends ControlPanelElement //A general string editor is not possible because strings cannot be edited without replacement.
{
  MapElement elementToEdit;
  private boolean editingActive = false;
  
  public static final int h = 35;

  private WindowCoordinates position;
  
  @Override
  public void loopActions()
  {
    //Ensure that this component iscannot behave as active while something else has exclusive keyboard control; this is most useful for removing active status when another component takes it.
    if(editingActive && exclusiveKeyboardInputUser != this)
    {
      editingActive = false;
    }
    
    if(editingActive)
    {
      stroke(spc.highlightedColour);
    }
    else
    {
      noStroke();
    }
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.deemphasizedTextColour);
    text("Display name:", position.x+10, position.y+15);
    
    fill(spc.textColour);
    text(elementToEdit.displayName, position.x+20, position.y+30);
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      editingActive = !editingActive; 
      if(editingActive)
      {
        exclusiveKeyboardInputUser = this;
      }
      else
      {
        exclusiveKeyboardInputUser = null;
      }
    }
  }
  
  @Override
  public void keyPressedActions()
  {
    if(editingActive)
    {
      if(key != CODED)
      {
        if(key == '\b') //backspace
        {
          if(elementToEdit.displayName.length() > 0)
          {
            elementToEdit.displayName = elementToEdit.displayName.substring(0, elementToEdit.displayName.length()-1);
          }
        }
        else
        {
          if(key == '\n' || key == '\r') //People naturally use the enter key to complete input in a text field.
          {
            editingActive = false;
            exclusiveKeyboardInputUser = null;
          }
          else
          {
            elementToEdit.displayName = elementToEdit.displayName + key;
          }
        }
      }
    }
  }
  
  public NametagEditorComponent(WindowCoordinates wc, MapElement elementToEdit)
  {
    position = wc;
    this.elementToEdit = elementToEdit;
  }
}

class NumberEditorComponent extends ControlPanelElement
{
  private boolean editingActive = false;
  private String editingString;
  color editingStringColour;
  
  Function<Double, Boolean> validityChecker;
  Consumer<Double> destination;
  Supplier<Double> valueReader;
  
  public static final int h = 35;
  
  WindowCoordinates position;
  String label;
  
  private boolean canConvertToDouble(String s)
  {
    try
    {
      Double test = new Double(s);
    }
    catch(NumberFormatException e)
    {
      return false;
    }
    return true;
  }
  
  private Double convertToDouble(String s)
  {
    try
    {
      return new Double(s);
    }
    catch(NumberFormatException e)
    {
      e.printStackTrace();
      return null;
    }
  }
  
  private boolean readyToUpdateDestination(String s)
  {
    if(!canConvertToDouble(s))
    {
      return false;
    }
    if(!validityChecker.apply(convertToDouble(s)))
    {
      return false;
    }
    return true;
  }
  
  private void updateEditingTextColour()
  {
    if(readyToUpdateDestination(editingString))
    {
      editingStringColour = spc.textColour;
    }
    else
    {
      editingStringColour = spc.falseColour;
    }
  }
  
  @Override
  public void loopActions()
  {
    if(editingActive && exclusiveKeyboardInputUser != this)
    {
      editingActive = false;
    }
    
    if(editingActive)
    {
      stroke(spc.highlightedColour);
    }
    else
    {
      noStroke();
    }
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.deemphasizedTextColour);
    text(label, position.x+10, position.y+15);
    
    fill(editingStringColour);
    text(editingString, position.x+20, position.y+30);
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      editingActive = !editingActive; 
      if(editingActive)
      {
        exclusiveKeyboardInputUser = this;
      }
      else
      {
        exclusiveKeyboardInputUser = null;
      }
    }
  }
  
  @Override
  public void keyPressedActions()
  {
    if(editingActive)
    {
      if(key != CODED)
      {
        if(key == '\b') //backspace
        {
          if(editingString.length() > 0)
          {
            editingString = editingString.substring(0, editingString.length()-1);
          }
        }
        else
        {
          if(key == '\n' || key == '\r') //People naturally use the enter key to complete input in a text field.
          {
            editingActive = false;
            exclusiveKeyboardInputUser = null;
          }
          else
          {
            editingString = editingString + key;
          }
        }
        
        updateEditingTextColour();
        if(readyToUpdateDestination(editingString))
        {
          editingStringColour = spc.textColour;
          destination.accept(convertToDouble(editingString));
          viewport.needRedraw = true;
        }
      }
    }
  }
  
  public NumberEditorComponent(WindowCoordinates position, Supplier<Double> valueReader, Consumer<Double> destination, Function<Double, Boolean> validityChecker, String label)
  {
    this.position = position;
    this.label = label;
    this.valueReader = valueReader;
    this.destination = destination;
    this.validityChecker = validityChecker;
    editingString = valueReader.get().toString();
    updateEditingTextColour();
  }
}

class DeletionEditorComponent extends ControlPanelElement
{
  MapElement elementToDelete;
  List deletionLocation; //the list from which to delete the element; this is required because this component should be usable for elements of lists contained inside top-level map elements.
  
  public static final int h = 20;

  private WindowCoordinates position;
  
  private boolean oneClickToDelete = false;
  
  @Override
  public void loopActions()
  {
    if(oneClickToDelete)
    {
      stroke(spc.highlightedColour);
    }
    else
    {
      noStroke();
    }
    fill(spc.elementBackgroundColour);
    rect(position.x, position.y, sidePanelWidth-2, h);
    
    fill(spc.falseColour);
    if(oneClickToDelete)
    {
      text("Confirm deletion", position.x+10, position.y+15);
    }
    else
    {
      text("Delete", position.x+10, position.y+15);
    }
  }
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      if(oneClickToDelete)
      {
        deletionLocation.remove(elementToDelete);
        viewport.needRedraw = true;
        sidePanelStack.pop(); //Pop the editor off the side panel stack because the entity it is editing has been deleted.
      }
      else
      {
        oneClickToDelete = true;
      }
    }
    else
    {
      //Any click outside the deletion button resets it.
      oneClickToDelete = false;
    }
  }
  
  public DeletionEditorComponent(WindowCoordinates position, MapElement elementToDelete, List deletionLocation)
  {
    this.position = position;
    this.elementToDelete = elementToDelete;
    this.deletionLocation = deletionLocation;
  }
}

class ExitEditorComponent extends ExitComponent
{
  EditorPanel panelToExit;
  
  @Override
  public void mousePressedActions()
  {
    if(mouseX > position.x && mouseX < position.x + sidePanelWidth && mouseY > position.y && mouseY < position.y + h) //if the click falls within the bounding box
    {
      exclusiveKeyboardInputUser = null;
      sidePanelStack.pop();
      panelToExit.close();
    }
  }
  
  public ExitEditorComponent(WindowCoordinates position, EditorPanel panelToExit)
  {
    super(position);
    this.panelToExit = panelToExit;
  }
}
