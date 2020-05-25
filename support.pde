import java.text.DecimalFormat;
import java.util.Locale;

final DecimalFormat coordinatesDisplayDecimalFormat = new DecimalFormat("0.0000");


class GeographicCoordinates
{
  public Double longitude;
  public Double latitude;
  
  GeographicCoordinates (Double latitude, Double longitude)
  {
    this.latitude = latitude;
    this.longitude = longitude;
  }
  
  @Override
  public String toString()
  {
    if(latitude == null || longitude == null)
    {
      return "invalid coordinates";
    }
    else
    {
      return coordinatesDisplayDecimalFormat.format(latitude) + ",  " + coordinatesDisplayDecimalFormat.format(longitude);
    }
  }
}

final double kerbinRadius = 600000; //metres

//This function implements an algorithm described at http://www.movable-type.co.uk/scripts/latlong.html.
GeographicCoordinates pointAtBearingAndDistance(GeographicCoordinates startingPoint, double bearing, double distance)
{
  double angularDistance = distance/kerbinRadius;
  
  double resultLatitude = Math.asin(
    Math.sin(startingPoint.latitude)*Math.cos(angularDistance) +
    Math.cos(startingPoint.latitude)*Math.sin(angularDistance)*Math.cos(bearing)
  );
  double resultLongitude = startingPoint.longitude + Math.atan2(
    Math.sin(bearing)*Math.sin(angularDistance)*Math.cos(startingPoint.latitude),
    Math.cos(angularDistance) - Math.sin(startingPoint.latitude)*Math.sin(resultLatitude)
  );
  
  //Convert results into degrees.
  resultLatitude *= (PI/180)*resultLatitude;
  resultLongitude = (PI/180)*resultLongitude;
  
  return new GeographicCoordinates(resultLatitude, resultLongitude);
}

double DistanceBetweenCoordinates(GeographicCoordinates c1, GeographicCoordinates c2)
{
  //This is done with multiplication because apparently the Processing conversion functions accept and return floats.
  //All latitudes and longitudes are converted to radians.
  double c1Lat = (PI/180)*c1.latitude;
  double c1Long = (PI/180)*c1.longitude;
  double c2Lat = (PI/180)*c2.latitude;
  double c2Long = (PI/180)*c2.longitude;
  
  //Wikipedia magic
  /*double centralAngle = 2*Math.asin(Math.sqrt(
    Math.pow(Math.sin((c1Long-c2Long)/2), 2) + 
    (Math.cos(c1Lat)*Math.cos(c2Lat)*Math.pow(Math.sin(c1Long-c2Long)/2, 2))
  )); //radians */
  
  double centralAngle = Math.acos(
    Math.sin(c1Lat)*Math.sin(c2Lat) + 
    Math.cos(c1Lat)*Math.cos(c2Lat)*Math.cos(Math.abs(c1Long-c2Long))
  );
  double answer = kerbinRadius * centralAngle;
  
  return answer;
}

//Algorithm from "Aviation formulary V1.46", http://www.edwilliams.org/avform.htm#Int
double latitudeOfGreatCircle(GeographicCoordinates c1, GeographicCoordinates c2, double longitude)
{
  //Convert all the coordinates to radians 
  double lat1 = (PI/180) * c1.latitude;
  double lat2 = (PI/180) * c2.latitude;
  double lon1 = (PI/180) * c1.longitude;
  double lon2 = (PI/180) * c2.longitude;
  double radiansLongitide = (PI/180) * longitude;
  
  double lat = Math.atan(
    (Math.sin(lat1)*Math.cos(lat2)*Math.sin(radiansLongitide-lon2) - Math.sin(lat2)*Math.cos(lat1)*Math.sin(radiansLongitide-lon1))
    / (Math.cos(lat1)*Math.cos(lat2)*Math.sin(lon1-lon2))
  );
  
  return (180/PI) * lat;
}

//This is an implementation of the cubehelix colour scheme from the paper at https://arxiv.org/pdf/1108.5083.pdf.
//The variables are named like they are in the paper.
color cubeHelix(double lambda)
{
  final double s = 300; //start colour
  final double r = -1.5; //number of rotations
  final double h = 1; //hue parameter
  final double gamma = 0.5;
  
  double phi = TWO_PI*(s/3.0d + r*lambda);
  double a = h*Math.pow(lambda,gamma)*(1-Math.pow(lambda,gamma))/2;
  
  double R = Math.pow(lambda,gamma) + a*(Math.cos(phi)*(-0.14861d) + Math.sin(phi)*(1.78277d));
  double G = Math.pow(lambda,gamma) + a*(Math.cos(phi)*(-0.29227d) + Math.sin(phi)*(-0.90649d));
  double B = Math.pow(lambda,gamma) + a*(Math.cos(phi)*(1.97294d) + Math.sin(phi)*(0));
  //print(R+" "+G+" "+B);
  //println(R + " " + );
  
  return color((int)Math.round(R*255),(int)Math.round(G*255),(int)Math.round(B*255));
}

String[] sampleLineListToProcess; //This is used to transfer the sample lines to the processing threads.
//ArrayList<ScalarSample> combinedSampleList; //This is used to store output from the sample file line processing threads.
ArrayList<ScalarSample>[] sampleListProcessingResults = new ArrayList[4]; //This is used to store output from the sample file line processing threads.
volatile boolean[] sampleLineProcessingDone = new boolean[4];

void processSampleFileLines(int instanceNumber, int startIndex, int endIndex)
{
  println("started sample file line processing on lines "+startIndex+" to "+endIndex);
  
  sampleListProcessingResults[instanceNumber] = new ArrayList<ScalarSample>(); //This will be deallocated elsewhere after the thread is done. Apparently, it is necessary to do both this and the new ArrayList[] at the declaration.
  //println(sampleListProcessingResults[instanceNumber]);
  
  for(int i=startIndex; i<endIndex; i++)
  {
    String temp = sampleLineListToProcess[i].replaceAll(",",""); //Remove the separating commas from the strings.
    //println(temp); //debug
    
    Scanner sc = new Scanner(temp);
    sc.useLocale(Locale.ENGLISH);
    double latitude = sc.nextDouble();
    double longitude = sc.nextDouble();
    double value = sc.nextDouble();
    sc.close();
    
    sampleListProcessingResults[instanceNumber].add(new ScalarSample(new GeographicCoordinates(latitude, longitude), value));
  }
  println("finished sample file line processing on lines "+startIndex+" to "+endIndex);
  sampleLineProcessingDone[instanceNumber] = true;
}

//sample file line processing threads
void sflp0()
{
  processSampleFileLines(0, 0,sampleLineListToProcess.length/4); 
}
void sflp1()
{
  processSampleFileLines(1, sampleLineListToProcess.length/4,2*(sampleLineListToProcess.length/4)); 
}
void sflp2()
{
  processSampleFileLines(2, 2*(sampleLineListToProcess.length/4),3*(sampleLineListToProcess.length/4)); 
}
void sflp3()
{
  processSampleFileLines(3, 3*(sampleLineListToProcess.length/4),sampleLineListToProcess.length); 
}
