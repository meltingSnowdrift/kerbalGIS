//This function estimates a value at point (x,y) given values at (0,0), (w,0), (0,h), and (w,h)
//q should be a 2 by 2 array
//q[0][0] is f(0,0), q[1][0] is f(w,0), and so on.
double distanceInterpolation(double x, double y, double w, double h, double[][] q)
{
  //[0][0] lower left
  //[1][0] upper left
  //[0][1] lower right
  //[1][1] upper right
  
  double[][] quack = new double[2][2];
  
  //Calculate distances.
  quack[0][0] = Math.sqrt(x*x + y*y);
  quack[1][0] = Math.sqrt(x*x + (h-y)*(h-y));
  quack[0][1] = Math.sqrt((w-x)*(w-x) + y*y);
  quack[1][1] = Math.sqrt((w-x)*(w-x) + (h-y)*(h-y));
  
  //Calculate reciprocals of distances.
  quack[0][0] = 1/quack[0][0];
  quack[1][0] = 1/quack[1][0];
  quack[0][1] = 1/quack[0][1];
  quack[1][1] = 1/quack[1][1];
  
  //Normalize.
  //The four multipliers should add up to 1.
  double a = 1.0d/(quack[0][0] + quack[1][0] + quack[0][1] + quack[1][1]);
  
  //Apply the normalization constant.
  quack[0][0] *= a;
  quack[1][0] *= a;
  quack[0][1] *= a;
  quack[1][1] *= a;
  
  return quack[0][0]*q[0][0] + quack[1][0]*q[1][0] + quack[0][1]*q[0][1] + quack[1][1]*q[1][1];
}

double bilinearInterpolation(double x, double y, double w, double h, double[][] q)
{
  double topSample = q[0][0] * (1 - x / w) +  q[0][1] * x / w;
  double bottomSample = q[1][0] * (1 - x / w) + q[1][1] * x / w;
  return topSample * (1 - y / h) + bottomSample * y / h;
}

double crudeInterpolation(double x, double y, double w, double h, double[][] q)
{
  //println("w/2 " + w/2 + " h/2 " + h/2);
  
  if(x < w/2) //left
  {
    //print("left ");
    if(y < h/2) //lower
    { 
      //print("lower");
      return q[0][0];
    }
    else //upper
    {
      //print("upper");
      return q[1][0];
    }
  }
  else //right
  {
    //print("right ");
    if(y < h/2) //lower
    {
      //print("lower");
      return q[0][1];
    }
    else //upper
    {
      //print("upper");
      return q[1][1];
    }
  }
}
