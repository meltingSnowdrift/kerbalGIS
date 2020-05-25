import java.util.Stack;
import java.math.RoundingMode;

ControlPanel mapPanel;
MapViewport viewport;

final int sidePanelWidth = 200;
Stack<SidePanel> sidePanelStack;

FieldFromSampleGrid quack;
FieldMapElement oink;

ArrayList<MapElement> mapElementList;

PApplet appletReference; //This is used in some editor panel stuff, which apparently requires the PApplet as an undeclared first argument.

ControlPanelElement exclusiveKeyboardInputUser = null;

void setup()
{
  appletReference = this;
  
  size(1200,750);
  noSmooth();
  coordinatesDisplayDecimalFormat.setRoundingMode(RoundingMode.HALF_UP);
  
  mapPanel = new ControlPanel();
  mapElementList = new ArrayList<MapElement>(); //This needs to happen before the viewport is initialized so that it can refer to this.
  viewport = new MapViewport(new WindowCoordinates(sidePanelWidth,height-1), width-sidePanelWidth, height, mapElementList);
  mapPanel.elements.add(viewport);
  
  sidePanelStack = new Stack<SidePanel>();
  ElementListPanel elp = new ElementListPanel();
  sidePanelStack.add(elp);
  
  
  quack = new FieldFromSampleGrid(3600,1800);
  quack.populateSampleGridFromFile("samples.txt");
  
  //quack.sampleGrid[900][1800] = 100;
  //quack.sampleGrid[901][1800] = 200;
  //quack.sampleGrid[900][1801] = 400;
  //quack.sampleGrid[901][1801] = 800;
  println("Terrain loading complete.");
  
  oink = new FieldMapElementFromScalarField(quack, "Base map");
  //oink = new FieldMapElementFromScalarField(new ZeroField());
  
  mapElementList.add(oink);
  
  System.gc();
  
  //Start rendering threads.
  thread("rt0");
  thread("rt1");
  thread("rt2");
  thread("rt3");
  
  //testing
  //mapElementList.add(new PointMarker(new GeographicCoordinates(10d,10d), "Quack"));
  //mapElementList.add(new PointMarker(new GeographicCoordinates(40d,40d), "Quack2"));
  //mapElementList.add(new FilledCircle(new GeographicCoordinates(10d, 10d), 500000d, "Oink"));
  //mapElementList.add(new GreatCircleSegment(new GeographicCoordinates(0d, 10d), new GeographicCoordinates(40d,-40d), "Moo")); 
  viewport.needRedraw = true;
}

void draw()
{
  mapPanel.loopActions();
  
  if(!sidePanelStack.empty())
  {
    sidePanelStack.peek().loopActions();
  }
}

void keyPressed()
{
  if(exclusiveKeyboardInputUser == null) //if there is no component exclusively capturing keyboard control
  {
    mapPanel.keyPressedActions();
    
    if(!sidePanelStack.empty())
    {
      sidePanelStack.peek().keyPressedActions();
    }
  }
  else //if there is a component exclusively capturing keyboard control
  {
    exclusiveKeyboardInputUser.keyPressedActions();
  }
}

void mousePressed()
{
  mapPanel.mousePressedActions();
  
  if(!sidePanelStack.empty())
  {
    sidePanelStack.peek().mousePressedActions();
  }
}

void geoClick(GeographicCoordinates clickedCoordinates)
{
  //mapElementList.add(new PointMarker(clickedCoordinates, "Quack")); viewport.needRedraw = true; //testing
  
  if(!sidePanelStack.empty())
  {
    sidePanelStack.peek().acceptGeoClick(clickedCoordinates);
  }
}
