
class PointMarkerEditorPanel extends EditorPanel
{
  private PointMarker editedObject()
  {
    return (PointMarker)editedObjectReference[0];
  }
  
  @Override
  protected boolean editedObjectValid()
  {
    if(editedObject().markedCoordinates.longitude == null)
    {
      return false;
    }
    if(editedObject().markedCoordinates.latitude == null)
    {
      return false;
    }
    
    return true;
  }
  
  public PointMarkerEditorPanel(Object[] editedObjectReference, List editedObjectDestination)
  {
    super(editedObjectReference, editedObjectDestination);
    
    if(!editingExistingObject())
    {
      PointMarker newEditedObject = new PointMarker(new GeographicCoordinates(null,null), "");
      editedObjectReference[0] = newEditedObject;
    }
    
    int nextY=1;
    elements.add(new CoordinatesEditorComponent(new WindowCoordinates(1,nextY), editedObject().markedCoordinates, "Marked coordinates:"));
    nextY += CoordinatesEditorComponent.h + 1;
    elements.add(new NametagEditorComponent(new WindowCoordinates(1, nextY), editedObject()));
    nextY += NametagEditorComponent.h + 1;
    elements.add(new DeletionEditorComponent(new WindowCoordinates(1, nextY), editedObject(), mapElementList));
    nextY += DeletionEditorComponent.h + 1;
    elements.add(new ExitEditorComponent(new WindowCoordinates(1, nextY), this));
  }
}
