
class MapViewport extends ControlPanelElement
{
  public class ViewportCoordinates //This is distinct from WindowCoordinates because the vewport has a different origin and an opposite y-axis direction.
  {
    int x;
    int y;
    
    boolean withinViewport()
    {
       return x>=0 && x<=w && y>=0 && y<=h; 
    }
    
    GeographicCoordinates toGeoCoordinates() //This can return null if this point in the viewport does not correspond to any geographic point, such as when it is 
    {
      if(!withinViewport()) //if the point is outside the viewport
      {
        return null;
      }
      
      double longitude = viewportGeoOrigin.longitude + x*degreesPerPixel;
      double latitude = viewportGeoOrigin.latitude + y*degreesPerPixel;
      
      //longitude wrappings
      while(longitude < -180)
      {
        longitude += 360;
      }
      while(longitude > 180)
      {
        longitude -= 360;
      }
      
      
      if(Math.abs(latitude) >= 90) //latitude cutoff
      {
        return null;
      }
      else
      {
        return new GeographicCoordinates(latitude, longitude);
      }
    }
    
    ViewportCoordinates(GeographicCoordinates gc)
    {
      double viewportRelativeLatitude = gc.latitude - viewportGeoOrigin.latitude;
      double viewportRelativeLongitude = gc.longitude - viewportGeoOrigin.longitude;
      
      if(viewportRelativeLongitude < 0)
      {
        viewportRelativeLongitude += 360;
      }
      
      x = (int)Math.round(viewportRelativeLongitude/degreesPerPixel);
      y = (int)Math.round(viewportRelativeLatitude/degreesPerPixel);
    }
    
    WindowCoordinates toWindowCoordinates()
    {
      if(withinViewport())
      {
        return new WindowCoordinates(position.x + x, position.y - y);
      }
      else
      {
        return null;
      }
    }
    
    ViewportCoordinates(WindowCoordinates wc)
    {
      this(wc.x - position.x, position.y - wc.y);
    }
    
    ViewportCoordinates(int x, int y)
    {
      this.x = x;
      this.y = y;
    }
  }
  
  //Display characteristics
  WindowCoordinates position;
  int w; //width
  int h; //height
  boolean needRedraw = true;
  List<MapElement> mapElements;
  
  //Physical characteristics
  GeographicCoordinates viewportGeoOrigin;
  double degreesPerPixel = 0.05;
  final double panningMultiplier = 5;
  final double zoomMultiplier = 1.5;
  
  public MapViewport(WindowCoordinates position, int w, int h, List<MapElement> mapElements)
  {
    this.position = position;
    this.w = w;
    this.h = h;
    this.mapElements = mapElements;
    
    //degreesPerPixel;
    //viewportGeoOrigin = new GeographicCoordinates(0,-75);
    viewportGeoOrigin = new GeographicCoordinates(-1d,-1d);
    //viewportGeoOrigin = new GeographicCoordinates(-200,0);
    
    //println(panningMultiplier);
    //println(degreesPerPixel);
    //println(panningMultiplier*degreesPerPixel);
    //println(mapElements);
  }
  
  public void render()
  {
    //Create a blank background to prevent ghosting of newly hidden elements
    noStroke();
    fill(color(0));
    rect(position.x, position.y+1, w, -h-1); //The reference position is at the lower left corner. ALso, it appears that the field rendering region is offset by 1 pixel downward from the specified region.
    //println(position.x + " " + position.y);
    //rect(0,0,100,100);
    
    //println(mapElements);
    for(int i=0; i<mapElements.size(); i++)
    {
      MapElement me = mapElements.get(i);
      if(me.shown)
      {
        me.render(this);
      }
    }
    
    stroke(color(255));
    line(position.x + w/2, (position.y-h/2)-10, position.x + w/2, (position.y-h/2)+10);
    line((position.x + w/2)-10, position.y-h/2, (position.x + w/2)+10, position.y-h/2);
    
    //drawGreatCircleSegment(new GeographicCoordinates(10d,10d), new GeographicCoordinates(40d,40d), color(255)); //debug
    
    needRedraw = false;
  }
  
  private void threadedRenderField(FieldMapElement fme)
  {
    //println("start render");
    
    fieldToRender = fme;
    loadPixels();
    //copiedPixels = pixels;
    
    //println("quack");
    renderStartSignal[0] = true; renderDone[0] = false; threadReferences[0].interrupt();
    renderStartSignal[1] = true; renderDone[1] = false; threadReferences[1].interrupt();
    renderStartSignal[2] = true; renderDone[2] = false; threadReferences[2].interrupt();
    renderStartSignal[3] = true; renderDone[3] = false; threadReferences[3].interrupt();
    
    while(!(renderDone[0] && renderDone[1] && renderDone[2] && renderDone[3]))
    {
      //Do nothing while waiting
    }
    
    updatePixels(); //This must be done every time because overlaid map elements, which use the normal drawing commands, may be drawn between two field map elements.
    //print("end render");
  }
  
  public void drawGreatCircleSegment(GeographicCoordinates p1, GeographicCoordinates p2, color c)
  {
    stroke(c);
    
    if(p1.longitude == p2.longitude) //If the two points are at the same longitude, the solution is trivial because lines of longitude are always vertical on this projection.
    {
      ViewportCoordinates v1 = new ViewportCoordinates(p1);
      ViewportCoordinates v2 = new ViewportCoordinates(p2);
      line(v1.x, v1.y, v2.x, v2.y);
    }
    else
    {
      double drawLongitude;
      double drawEndLongitude;
      
      //Initialize the state variables at the starting point, which here is the point for which proceeding in the forrect direction increases longitude.
      //longitude differences from p1 to p2 
      double positiveDistance;
      double negativeDistance;
      if(p1.longitude < p2.longitude)
      {
        positiveDistance = p2.longitude-p1.longitude;
        negativeDistance = 360-positiveDistance;
      }
      else
      {
        negativeDistance = p1.longitude-p2.longitude;
        positiveDistance = 360-negativeDistance;
      }
      
      if(positiveDistance<negativeDistance)
      {
        drawLongitude = p1.longitude;
        drawEndLongitude = p2.longitude;
      }
      else
      {
        drawLongitude = p2.longitude;
        drawEndLongitude = p1.longitude;
      }
      
      GeographicCoordinates drawPoint = new GeographicCoordinates(latitudeOfGreatCircle(p1,p2,drawLongitude), drawLongitude);
      while(Math.abs(drawLongitude - drawEndLongitude) >= degreesPerPixel)
      {
        GeographicCoordinates previousDrawPoint = drawPoint;
        
        drawLongitude += degreesPerPixel;
        //Longitude wrapping
        while(drawLongitude < -180)
        {
          drawLongitude += 360;
        }
        while(drawLongitude > 180)
        {
          drawLongitude -= 360;
        }
        
        drawPoint = new GeographicCoordinates(latitudeOfGreatCircle(p1,p2,drawLongitude), drawLongitude);
        
        WindowCoordinates previousDrawWC = new ViewportCoordinates(previousDrawPoint).toWindowCoordinates();
        WindowCoordinates currentDrawWC = new ViewportCoordinates(drawPoint).toWindowCoordinates();
        if(previousDrawWC != null && currentDrawWC != null)
        {
          line(previousDrawWC.x, previousDrawWC.y, currentDrawWC.x, currentDrawWC.y);
        }
      }
    }
  }
  
  @Override
  public void loopActions()
  {
    if(needRedraw)
    {
      render();
    }
  }
  
  public void keyPressedActions()
  {
    if(key == CODED)
    {
      if(keyCode == UP)
      {
        viewportGeoOrigin.latitude += panningMultiplier*degreesPerPixel;
        needRedraw = true;
      }
      if(keyCode == DOWN)
      {
        viewportGeoOrigin.latitude -= panningMultiplier*degreesPerPixel;
        needRedraw = true;
      }
      if(keyCode == LEFT)
      {
        viewportGeoOrigin.longitude -= panningMultiplier*degreesPerPixel;
        needRedraw = true;
      }
      if(keyCode == RIGHT)
      {
        viewportGeoOrigin.longitude += panningMultiplier*degreesPerPixel;
        needRedraw = true;
      }
    }
    //println("origin lat " + viewportGeoOrigin.latitude + " long " + viewportGeoOrigin.longitude);
    
    if(key == '+')
    {
      viewportGeoOrigin.longitude += (w - ((double)w)/zoomMultiplier) * degreesPerPixel * 0.5;
      viewportGeoOrigin.latitude += (h - ((double)h)/zoomMultiplier) * degreesPerPixel * 0.5;
      degreesPerPixel /= zoomMultiplier;
      needRedraw = true;
    }
    if(key == '-')
    {
      viewportGeoOrigin.longitude -= (((double)w)*zoomMultiplier - w) * degreesPerPixel * 0.5;
      viewportGeoOrigin.latitude -= (((double)h)*zoomMultiplier - h) * degreesPerPixel * 0.5;
      degreesPerPixel *= zoomMultiplier;
      needRedraw = true;
    }
    
    if(Math.abs(viewportGeoOrigin.longitude) > 180)
    {
      viewportGeoOrigin.longitude -= Math.signum(viewportGeoOrigin.longitude)*360;
    }
  }
  
  @Override
  public void mousePressedActions()
  {
    ViewportCoordinates vc = new ViewportCoordinates(new WindowCoordinates(mouseX, mouseY));
    if(vc.toGeoCoordinates() != null) //if the clicked point validly correponds to geographic coordinates
    {
      geoClick(vc.toGeoCoordinates());
    }
  }
}
