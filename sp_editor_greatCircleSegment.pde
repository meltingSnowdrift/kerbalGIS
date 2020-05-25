

class GreatCircleSegmentEditorPanel extends EditorPanel
{
  private GreatCircleSegment editedObject()
  {
    return (GreatCircleSegment)editedObjectReference[0];
  }
  
  @Override
  protected boolean editedObjectValid()
  {
    if(editedObject().c1.longitude == null)
    {
      return false;
    }
    if(editedObject().c1.latitude == null)
    {
      return false;
    }
    if(editedObject().c2.longitude == null)
    {
      return false;
    }
    if(editedObject().c2.latitude == null)
    {
      return false;
    }
    
    return true;
  }
  
  public GreatCircleSegmentEditorPanel(Object[] editedObjectReference, List editedObjectDestination)
  {
    super(editedObjectReference, editedObjectDestination);
    
    if(!editingExistingObject())
    {
      GreatCircleSegment newEditedObject = new GreatCircleSegment(new GeographicCoordinates(null,null), new GeographicCoordinates(null,null), "");
      editedObjectReference[0] = newEditedObject;
    }
    
    int nextY=1;
    elements.add(new CoordinatesEditorComponent(new WindowCoordinates(1,nextY), editedObject().c1, "Start coordinates:"));
    nextY += CoordinatesEditorComponent.h + 1;
    elements.add(new CoordinatesEditorComponent(new WindowCoordinates(1,nextY), editedObject().c2, "End coordinates:"));
    nextY += CoordinatesEditorComponent.h + 1;
    elements.add(new NametagEditorComponent(new WindowCoordinates(1, nextY), editedObject()));
    nextY += NametagEditorComponent.h + 1;
    elements.add(new DeletionEditorComponent(new WindowCoordinates(1, nextY), editedObject(), mapElementList));
    nextY += DeletionEditorComponent.h + 1;
    elements.add(new ExitEditorComponent(new WindowCoordinates(1, nextY), this));
  }
}
