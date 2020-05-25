
class GreatCircleSegment extends OverlaidMapElement
{
  GeographicCoordinates c1;
  GeographicCoordinates c2;
  
  @Override
  public void render(MapViewport vp)
  {
    WindowCoordinates wc1 = vp.new ViewportCoordinates(c1).toWindowCoordinates();
    WindowCoordinates wc2 = vp.new ViewportCoordinates(c2).toWindowCoordinates();
    
    stroke(color(255));
    
    if(wc1 != null)
    {
      noFill();
      circle(wc1.x, wc1.y, 4);
      if(highlighted)
      {
        circle(wc1.x, wc1.y, 9);
      }
    }
    
    if(wc2 != null)
    {
      fill(color(255));
      circle(wc2.x, wc2.y, 4);
      if(highlighted)
      {
        noFill();
        circle(wc2.x, wc2.y, 9);
      }
    }
    
    vp.drawGreatCircleSegment(c1,c2,color(255));
  }
  
  public GreatCircleSegment(GeographicCoordinates c1, GeographicCoordinates c2, String displayName)
  {
    this.c1 = c1;
    this.c2 = c2;
    this.displayName = displayName;
    this.elementTypeDisplayName = "great circle segment";
    editorPanel = GreatCircleSegmentEditorPanel.class;
  }
}
