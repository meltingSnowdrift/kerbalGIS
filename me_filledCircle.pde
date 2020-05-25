
class FilledCircle extends FieldMapElement
{
  GeographicCoordinates centre;
  double radius; //metres
  
  @Override
  color evaluateAtLocation(GeographicCoordinates gc)
  {
    if(DistanceBetweenCoordinates(gc, centre) < radius)
    {
      return color(255,0,0, 128);
    }
    else
    {
      return color(0,0,0,0);
    }
  }
  
  public FilledCircle(GeographicCoordinates centre, double radius, String displayName)
  {
    this.centre = centre;
    this.radius = radius;
    this.displayName = displayName;
    this.elementTypeDisplayName = "filled circle";
    editorPanel = FilledCircleEditorPanel.class;
  }
}
