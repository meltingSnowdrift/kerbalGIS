
class PointMarker extends OverlaidMapElement
{
  GeographicCoordinates markedCoordinates;
  
  @Override
  public void render(MapViewport vp)
  {
    MapViewport.ViewportCoordinates vc = vp.new ViewportCoordinates(markedCoordinates);
    if(vc.withinViewport())
    {
      WindowCoordinates wc = vc.toWindowCoordinates();
      
      noStroke();
      fill(color(255,0,0));
      circle(wc.x, wc.y, 10);
      
      noStroke();
      fill(color(0,255,0));
      circle(wc.x, wc.y, 3);
      
      if(highlighted)
      {
        stroke(color(255));
        noFill();
        circle(wc.x, wc.y, 15);
      }
    }
  }
  
  public PointMarker(GeographicCoordinates gc, String displayName)
  {
    elementTypeDisplayName = "point marker";
    editorPanel = PointMarkerEditorPanel.class;
    
    markedCoordinates = gc;
    this.displayName = displayName;
  }
}
