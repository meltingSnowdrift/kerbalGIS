
//If the signals are not volatile, the compiler will optimize away the render threads. 
volatile boolean[] renderStartSignal = new boolean[4]; //set by main program to start a render, unset by render threads as soon as they start working
volatile boolean[] renderDone = new boolean[4]; //set by render threads, unset by main program before starting a render
Thread[] threadReferences = new Thread[4];

FieldMapElement fieldToRender;
color invalidLatitudeColour = color(25);
//color[] copiedPixels;

void rt0()
{
  fieldRenderThread(0, 0, viewport.w/4);
}
void rt1()
{
  fieldRenderThread(1, viewport.w/4, 2*(viewport.w/4));
}
void rt2()
{
  fieldRenderThread(2, 2*(viewport.w/4), 3*(viewport.w/4));
}
void rt3()
{
  fieldRenderThread(3, 3*(viewport.w/4), viewport.w);
}

void fieldRenderThread(int instanceNumber, int startViewportX, int endViewportX)
{
  //initial setup
  renderStartSignal[instanceNumber] = false;
  renderDone[instanceNumber] = false;
  threadReferences[instanceNumber] = Thread.currentThread();
  
  while(true)
  {
    try
    {
      Thread.sleep(1000);
    }
    catch(InterruptedException e)
    {
      //Nothing needs to go here  because control falls to the rendering code when sleep is interrupted.
    }
    //println("quack " + instanceNumber); //debug; apparently things stop working when this is removed
    if(renderStartSignal[instanceNumber]) //Because control can get here after the natural end of a sleep call, this check is still needed.
    {
      //println("rt "+instanceNumber+" got start signal");
      renderStartSignal[instanceNumber] = false;
      
      renderVerticalSlice(startViewportX, endViewportX, fieldToRender);
      
      renderDone[instanceNumber] = true;
    }
  }
}

void renderVerticalSlice(int startViewportX, int endViewportX, FieldMapElement fme)
{
  for(int x = startViewportX; x<endViewportX; x++)
  {
    for(int y = 0; y<viewport.h; y++)
    {
      MapViewport.ViewportCoordinates vc = viewport.new ViewportCoordinates(x,y);
      WindowCoordinates wc = vc.toWindowCoordinates();
      
      if(wc != null)
      {
        GeographicCoordinates gc = vc.toGeoCoordinates();
        
        if(gc != null)
        {
          color c = fme.evaluateAtLocation(vc.toGeoCoordinates());
          if(alpha(c) !=0) //if not transparent
          {
            if(alpha(c) == 255)
            {
              setPixel(wc.x, wc.y, c);
            }
            else
            {
              //it is translucent
              setPixel(wc.x, wc.y, lerpColor(getPixel(wc.x, wc.y), c, (float)alpha(c)/255f));
            }
          }
        }
        else
        {
          //If a vlewport location has a valid screen location but not a valid geographic location, it should be outside the valid latitude range.
          //Set a predefined colour for such cases.
          setPixel(wc.x,wc.y,invalidLatitudeColour);
        }
      }
    }
  }
}

//This modifies the specified pixel in pixels[].
//This assumes that loadPixels has already been called.
void setPixel(int x, int y, color c)
{
  //println(pixels.length);
  //println(copiedPixels.length);
  int index = (width*y) + x;
  //println("setting "+x+" "+y+" -> "+index);
  pixels[index] = c;
  //copiedPixels[index] = c;
}

color getPixel(int x, int y)
{
  int index = (width*y) + x;
  return pixels[index];
}
