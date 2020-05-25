
class FilledCircleEditorPanel extends EditorPanel
{
  Function<Double, Boolean> radiusValidityChecker = new Function<Double,Boolean>()
  {
    @Override
    Boolean apply(Double d)
    {
      return d > 0 && Double.isFinite(d);
    }
  };
  
  Consumer<Double> radiusUpdater = new Consumer<Double>()
  {
    @Override
    void accept(Double d)
    {
      editedObject().radius = d;
    }
  };
  
  Supplier<Double> radiusReader = new Supplier<Double>()
  {
    @Override
    Double get()
    {
      return editedObject().radius;
    }
  };
  
  private FilledCircle editedObject()
  {
    return (FilledCircle)editedObjectReference[0];
  }
  
  @Override
  protected boolean editedObjectValid()
  {
    if(editedObject().centre.longitude == null)
    {
      return false;
    }
    if(editedObject().centre.latitude == null)
    {
      return false;
    }
    if(editedObject().radius <= 0)
    {
      return false;
    }
    
    return true;
  }
  
  public FilledCircleEditorPanel(Object[] editedObjectReference, List editedObjectDestination)
  {
    super(editedObjectReference, editedObjectDestination);
    
    if(!editingExistingObject())
    {
      FilledCircle newEditedObject = new FilledCircle(new GeographicCoordinates(null,null), 0d, "");
      editedObjectReference[0] = newEditedObject;
    }
    
    int nextY = 1;
    elements.add(new CoordinatesEditorComponent(new WindowCoordinates(1,nextY), editedObject().centre, "Centre:"));
    nextY += CoordinatesEditorComponent.h + 1;
    elements.add(new NumberEditorComponent(new WindowCoordinates(1, nextY), radiusReader, radiusUpdater, radiusValidityChecker, "Radius:"));
    nextY += NumberEditorComponent.h + 1;
    elements.add(new NametagEditorComponent(new WindowCoordinates(1, nextY), editedObject()));
    nextY += NametagEditorComponent.h + 1;
    elements.add(new DeletionEditorComponent(new WindowCoordinates(1, nextY), editedObject(), mapElementList));
    nextY += DeletionEditorComponent.h + 1;
    elements.add(new ExitEditorComponent(new WindowCoordinates(1, nextY), this));
  }
}
