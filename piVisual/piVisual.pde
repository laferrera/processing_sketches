final float diameter = 700; //the diameter of the circle
color[] digitColor = new color[10]; //The color of each digit
float[] currentDigitAngle = new float[10]; //Keep track of the last angle used for each digit (each time a line goes to the digit, the line is offset)
float[] digitAngleStep = new float[10]; //Store the step to add every time the line goes to a digit
int pos; //Keep track of the current digits beeing displayed if the draw function is used
int[] digit; //All the digit of PI

void setup() {
  size(1920, 1080); 
  background(0);
  translate(width/2, height/2);
  noFill();
  stroke(255);
  textAlign(CENTER, CENTER);
  strokeWeight(5);

  //Variables
  String dataString; //all the PI number as string

  int[] digitCount = new int[10]; //The amount of each deach from 0 to 9
  float[] digitWeight = new float[10]; //The proportion of each digit from 0 to 9
  final float angleGap = 0.03; //The gap between each arc
  float[] digitAngleSize = new float[10]; //The size of each digit arc 
  float currentAngle; //Use to keep track of the last arc drawn on screen in order the draw the next one after
  PFont myFont; //The font used for the text


  //Initialize variables
  myFont = loadFont("C64ProMono-10.vlw");
  //myFont = createFont("data/Comfortaa-Regular.ttf", 40);
  textFont(myFont);
  textSize(diameter / 10);
  text("π", -5, -10);
  textSize(diameter / 30);
  pos = 0;

  digitColor[0] = color(236, 166, 15);
  digitColor[1] = color(232, 125, 27);
  digitColor[2] = color(227, 45, 42);
  digitColor[3] = color(210, 0, 64);
  digitColor[4] = color(168, 11, 95);
  digitColor[5] = color(135, 46, 134);
  digitColor[6] = color(91, 77, 163);
  digitColor[7] = color(46, 116, 157);
  digitColor[8] = color(30, 154, 119);
  digitColor[9] = color(91, 176, 90);


  //Load data from string
  dataString = loadStrings("digits.txt")[0];

  //Transform data to integer and get count
  digit = new int[dataString.length()];

  for (int i = 0; i < dataString.length(); i++) {
    digit[i] = Character.getNumericValue(dataString.charAt(i));
    println(i);
    digitCount[digit[i]]++;
  }


  //Find weight and angle
  for (int i = 0; i < 10; i++) {
    digitWeight[i] = (float)digitCount[i] / digit.length;
    digitAngleSize[i] = digitWeight[i] * (TWO_PI - (10 * angleGap));
    if (digitCount[i] == 1) {
      digitAngleStep[i] = 0;
    } else {
      digitAngleStep[i] = digitAngleSize[i] / (digitCount[i] - 1);
    }
  }


  //Draw arcs and text
  currentAngle = (3 * PI / 2) - (digitAngleSize[0] / 2);
  for (int i = 0; i < 10; i++) {
    //Arcs
    stroke(red(digitColor[i]), green(digitColor[i]), blue(digitColor[i]));
    noFill();
    arc(0, 0, diameter, diameter, currentAngle, currentAngle+digitAngleSize[i]);
    currentDigitAngle[i] = currentAngle;

    //Text
    fill(red(digitColor[i]), green(digitColor[i]), blue(digitColor[i]));
    text(i, 1.1 * (diameter / 2) * cos((2*currentAngle+digitAngleSize[i])/2), 1.1 * (diameter/2) * sin((2*currentAngle+digitAngleSize[i])/2));

    currentAngle = currentAngle + digitAngleSize[i] + angleGap;
  }


  //*******
  //COMMENT THOSE LINES IF YOU USE THE DRAW FUNCTION
  //*******

  //Draw bezier curves
  for (int i = 0; i < digit.length - 1; i++) {
    drawBezier(currentDigitAngle[digit[i]], currentDigitAngle[digit[i+1]], digitColor[digit[i]]);
    currentDigitAngle[digit[i]] += digitAngleStep[digit[i]];
  }

  //*******
}


void draw() {
  //*******
  //UNCOMMENT THOSE LINES TO SEE THE DRAWING PROCESS
  //*******

  //translate(width/2, height/2);

  //for (int i = 0; i < 10; i++) {
  //  if (pos < digit.length - 1) {
  //    drawBezier(currentDigitAngle[digit[pos]], currentDigitAngle[digit[pos+1]], digitColor[digit[pos]]);
  //    currentDigitAngle[digit[pos]] += digitAngleStep[digit[pos]];
  //    pos++;
  //  }
  //}
}



// Function called to draw the bezier curves between two points
// angle1 is the angle of the first point
// angle2 is the angle od the second point
// Stroke color is the color used for the line
void drawBezier(float angle1, float angle2, color strokeColor) {
  float x1, y1, x2, y2, r, controlAngle1, controlAngle2, controlR;

  r = (diameter / 2) - 6;

  x1 = r * cos(angle1);
  y1 = r * sin(angle1);
  x2 = r * cos(angle2);
  y2 = r * sin(angle2);

  noFill();
  stroke(red(strokeColor), green(strokeColor), blue(strokeColor), 5);
  strokeWeight(2);

  //Different method is used in order to avoid line in the middle section
  if (angleDiff(x1, y1, x2, y2, 0, 0) < 0.3) {
    controlAngle1 = getAngle(x1, y1, 0, 0) + 0.5;
    controlAngle2 = getAngle(x2, y2, 0, 0) - 0.5;
    controlR = 0.9 * dist(x1, y1, 0, 0);
    bezier(x1, y1, x1 + controlR * cos(controlAngle1), y1 + controlR * sin(controlAngle1), x2 + controlR * cos(controlAngle2), y2 + controlR * sin(controlAngle2), x2, y2);
  } else {
    bezier(x1, y1, x1/2, y1/2, x2/2, y2/2, x2, y2);
  }
}





//Get angle from point 1 to point 2
float getAngle(float x1, float y1, float x2, float y2) {
  float angle;

  if (x2==x1) {
    if (y1>y2) {
      return HALF_PI;
    } else {
      return -HALF_PI;
    }
  }

  angle = atan((y2-y1)/(x2-x1));
  if (x1 > x2) {
    return angle + PI;
  } else {
    return angle;
  }
}


//Angle difference between pt1-2 and p1-3
float angleDiff(float x1, float y1, float x2, float y2, float x3, float y3) {
  float a1, a2, aDiff;
  a1 = getAngle(x1, y1, x2, y2);
  a2 = getAngle(x1, y1, x3, y3);

  aDiff = abs(a1 - a2);
  if (aDiff > PI) {
    if (a1>a2) {
      while (a1>a2) {
        a1 = a1 - TWO_PI;
      }
    } else {
      while (a1<a2) {
        a1 = a1 + TWO_PI;
      }
    }
  }
  aDiff = abs(a1 - a2);

  return aDiff;
}
