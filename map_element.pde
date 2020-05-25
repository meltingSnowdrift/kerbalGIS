
//There may exist subclasses of this class other than the two defined here. For example, waypoints on a path may be treated as MapElement instances which are not of wither subclass because they are neither fields nor require a separate render method. 
abstract class MapElement
{
  String elementTypeDisplayName; //Used in the UI as the name of the type of map element
  String displayName; //Used in the UI in lists of map elements to distinguish map elements, including those of the same type, from each other
  boolean shown = true;
  Class editorPanel = null;
  boolean highlighted = false;
  
  abstract public void render(MapViewport vp); //This method was added here because some map elements may require a combination of field and overlaid rendering methods, may be composites of various internal map elements, or may require neither standard rendering method. 
}

//These are map elements, such as the terrain height layer and filled circles, that provide a colour or transparency for every pixel.
//They can provide a colour or transparency for an arbitrary geographical location.
abstract class FieldMapElement extends MapElement
{
  abstract color evaluateAtLocation(GeographicCoordinates gc);
  
  @Override
  void render(MapViewport vp)
  {
    vp.threadedRenderField(this);
  }
}

abstract class OverlaidMapElement extends MapElement
{
  @Override
  abstract public void render(MapViewport vp); //render this element in the provided viewport; this is redundant now but might need to be modified again 
}
