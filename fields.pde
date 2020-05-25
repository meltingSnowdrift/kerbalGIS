import java.util.List;
import java.util.Scanner;
import java.util.Arrays;

abstract class ScalarField
{
  abstract double evaluateAtLocation(GeographicCoordinates gc);
}

class FieldMapElementFromScalarField extends FieldMapElement
{
  ScalarField sf;
  final double highestAltitueOnKerbin = 6764.1; //from KSP wiki
  
  @Override
  color evaluateAtLocation(GeographicCoordinates gc)
  {
    double fieldValue = sf.evaluateAtLocation(gc);
    
    //Implement a colour scale here.
    if(fieldValue<=0)
    {
      return color(0,0,255);
    }
    else
    {
      return cubeHelix(fieldValue/highestAltitueOnKerbin);
    }
  }
  
  FieldMapElementFromScalarField(ScalarField sf, String displayName)
  {
    elementTypeDisplayName = "scalar field display";
    this.sf = sf;
    this.displayName = displayName;
  }
}

class ZeroField extends ScalarField
{
  @Override
  double evaluateAtLocation(GeographicCoordinates gc)
  {
    return 0;
  }
}

//This class determines a field by interpolation of a 2-dimensional grid of evenly spaced samples.
class FieldFromSampleGrid extends ScalarField
{
  double[][] sampleGrid; //[latitude slice] [longitude slice]; [row][column]
  //float[][] sampleGrid; //[latitude slice] [longitude slice]; [row][column]
  int sampleGridWidth; //how many longitude slices there are 
  int sampleGridHeight; //how many latitude slices there are
  double horizontalSpacing; //how many degrees of longitude between adjacent longitude slices
  double verticalSpacing; //how many degrees of latitude between adjacent latitude slices
  
  @Override
  double evaluateAtLocation(GeographicCoordinates gc)
  {
    //Apply offsets to account for the origin of the sample grid being at -180 latitude and 180 longitude
    double latitudeOnGrid = gc.latitude + 90; //[-90,90] -> [0,180]
    double longitudeOnGrid = gc.longitude +180; //[-180,180] -> [0,360]
    
    int lowLatitudeSlice = (int)Math.floor(latitudeOnGrid/verticalSpacing);
    int highLatitudeSlice = lowLatitudeSlice + 1;
    int lowLongitudeSlice = (int)Math.floor(longitudeOnGrid/horizontalSpacing);
    int highLongitudeSlice = (lowLongitudeSlice + 1) % sampleGridWidth;
    
    //Distances from (low,low)
    double latitudeOffset = latitudeOnGrid % verticalSpacing;
    double longitudeOffset = longitudeOnGrid % horizontalSpacing;
    
    //Set up the interpolation reference points.
    double[][] interpolationValues = new double[2][2]; //[up/down][left/right]
    
    interpolationValues[0][0] = sampleGrid[lowLatitudeSlice][lowLongitudeSlice]; //bottom left
    interpolationValues[1][0] = sampleGrid[highLatitudeSlice][lowLongitudeSlice]; //top left
    interpolationValues[0][1] = sampleGrid[lowLatitudeSlice][highLongitudeSlice]; //bottom right
    interpolationValues[1][1] = sampleGrid[highLatitudeSlice][highLongitudeSlice]; //top right
    
    double answer = bilinearInterpolation(longitudeOffset, latitudeOffset, horizontalSpacing, verticalSpacing, interpolationValues);
    
    return answer;
  }
  
  void populateSampleGridFromSampleList(List<ScalarSample> sampleList)
  {
    for(ScalarSample s : sampleList)
    {
      int latitudeSlice = (int)Math.round((s.location.latitude + 90)/verticalSpacing);
      int longitudeSlice = (int)Math.round((s.location.longitude + 180)/horizontalSpacing);
      sampleGrid[latitudeSlice][longitudeSlice] = s.value;
      //println("populated " + latitudeSlice + " " + longitudeSlice + " value " + s.value); //debug
    }
  }
  
  void populateSampleGridFromFile(String filePath)
  {
    //ArrayList<ScalarSample> sampleList = new ArrayList<ScalarSample>();
    println("Loading lines from " + filePath);
    String[] fileLines = loadStrings(filePath);
    println("Lines loaded with "+fileLines.length+" samples.");
    //delay(10000000);//739 mb
    
    //Provide references for the threads.
    sampleLineListToProcess = fileLines;
    //sampleListProcessingResults = new ArrayList[4]; //Including the arraylist content type here results in a compiler error.
    //combinedSampleList = sampleList;
    
    //Start the threads.
    thread("sflp0");
    thread("sflp1");
    thread("sflp2");
    thread("sflp3");
    
    //Wait until all the threads are done.
    while(!(sampleLineProcessingDone[0] && sampleLineProcessingDone[1] && sampleLineProcessingDone[2] && sampleLineProcessingDone[3]))
    {
    }
    
    //Combine the result lists.
    println("Combining lists.");
    //sampleList.addAll(sampleListProcessingResults[0]);
    //sampleList.addAll(sampleListProcessingResults[1]);
    //sampleList.addAll(sampleListProcessingResults[2]);
    //sampleList.addAll(sampleListProcessingResults[3]);
    populateSampleGridFromSampleList(sampleListProcessingResults[0]);
    populateSampleGridFromSampleList(sampleListProcessingResults[1]);
    populateSampleGridFromSampleList(sampleListProcessingResults[2]);
    populateSampleGridFromSampleList(sampleListProcessingResults[3]);
    
    //Unset the global references to allow the associated resources to be freed.
    sampleLineListToProcess = null;
    sampleListProcessingResults = null;
    //fileLines = null;
    //System.gc();
    //delay(10000000);//2513 mb
    
    println("Sample list populated.");
    
    //populateSampleGridFromSampleList(sampleList);
    println("Sample grid populated.");
    //sampleList = null;
    //System.gc();
    //delay(10000000);//2514.4 mb
  }
  
  public FieldFromSampleGrid(int sampleGridWidth, int sampleGridHeight)
  {
    this.sampleGridWidth = sampleGridWidth;
    this.sampleGridHeight = sampleGridHeight;
    horizontalSpacing = 360.0d/sampleGridWidth;
    verticalSpacing = 180.0d/sampleGridHeight;
    
    sampleGrid = new double[sampleGridHeight+1][sampleGridWidth+1]; // There needs to be one more sample in each dimension than there are subdivisions.
    //sampleGrid = new float[sampleGridHeight+1][sampleGridWidth+1]; // There needs to be one more sample in each dimension than there are subdivisions.
  }
}

class ScalarSample
{
  GeographicCoordinates location;
  double value;
  
  public ScalarSample(GeographicCoordinates location, double value)
  {
    this.location = location;
    this.value = value;
  }
}
