import oscP5.*;
import netP5.*;
import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;
OscP5 oscP5;
NetAddress myRemoteLocation;

int cols;
int rows;
float[][][] current;// = new float[cols][rows];
float[][][] previous;// = new float[cols][rows];
float[][] noise;


float dampening = .99;
int timer;
PFont font;
String letterOrder = "  .`-_':/;▁▂▃░⋰_◜◠+*`=?!¬░█▄▀▀▁▂▃▄▅▆▇█▖▗▘▙▚▛▜▝▞▟═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬▩▪▫▬▭▮▯▰▱◖◗◜◝◞◟◠◡◸◹◺◿░▒▓";
char[] letters;  
float fontSize = 12.0;

float[] bright;
float brightDamp = 0.1;
float pixelOffset = 1.0;
float letterIndexScale = 1.0;
Boolean greyScale = false;
Boolean addInverseLetters = true;

int displayMode = 0;

void setup() {
  size(720, 360);
  frameRate(24);
  cols = width;
  rows = height;
  current = new float[cols][rows][3];
  previous = new float[cols][rows][3];
  noise = new float[cols][rows];
  //generate2DNoise();
  oscP5 = new OscP5(this,10101);
  myRemoteLocation = new NetAddress("127.0.0.1",10102);

  font = loadFont("C64ProMono-10.vlw");
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }

  int pixelCount = int(width * height / fontSize);
  bright = new float[pixelCount];
  for (int i = 0; i < pixelCount; i++) {
    // set each brightness to black
    bright[i] = 0;
  }
    //String exportFolder = sketchPath().getParent();
  // videoExport = new VideoExport(this, "myVideo.mp4");
  // videoExport.setFrameRate(30);  
  // videoExport.startMovie();
  // delay(1000);
}


void keyPressed() {
  switch (key) {
    case 'g': saveFrame(); break;
    // case 'c': cheatScreen = !cheatScreen; break;
    case 'b': brightDamp *= 1.1; println("brightDamp: ", brightDamp);break;
    case 'B': brightDamp *= 0.9; println("brightDamp: ", brightDamp);break;
    case 'p': pixelOffset *= 1.1; println("pixelOffset: ", pixelOffset); break;
    case 'P': pixelOffset *= 0.9; println("pixelOffset: ", pixelOffset); break;
    case 'f': fontSize *= 1.1; break;
    case 'F': fontSize *= 0.9; break;
    case 'q': { videoExport.endMovie(); exit();}
    case 'c': {displayMode = (displayMode + 1)%3; }
  }
}

void mouseDragged() {
  startRipple(mouseX, mouseY, 5000);
}

void mousePressed() {
  startRipple(mouseX, mouseY, 5000);
}

void randomRipple() {
  int x = int(random(0, width));
  int y = int(random(0, height));
  startRipple(x, y, 500000);
}

void oscEvent(OscMessage incomingMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+incomingMessage.addrPattern());
  println(" typetag: "+incomingMessage.typetag());
  //randomRipple();
  int x = int(incomingMessage.get(0).floatValue());
  int y = int(incomingMessage.get(1).floatValue());
  print(" x value: "+x);
  print(" y value: "+y);
  x = x * (width / 16);
  y = y * (height / 8);
  startRipple(x, y, 0);
}

void startRipple(int x,int y,int c){
  // previous[mouseX][mouseY] = color(255,0,0);
  int r = int(random(128, 50000));
  int g = int(random(128, 50000));
  int b = int(random(128, 50000));
  // color thisColor = color(r,g,b);
  // color thisColor = color(255,0,0);
  previous[x][y][0] = r;
  previous[x][y][1] = g;
  previous[x][y][2] = b;

  x = max(x,0);
  x = min(x, width);
  y = max(y,0);
  y = min(y, height);
  previous[x-2][y][0] = r;
  previous[x+2][y][0] = r;
  previous[x][y-2][0] = r;
  previous[x][y+2][0] = r;
  previous[x-2][y][1] = g;
  previous[x+2][y][1] = g;
  previous[x][y-2][1] = g;
  previous[x][y+2][1] = g;
  previous[x-2][y][2] = b;
  previous[x+2][y][2] = b;
  previous[x][y-2][2] = b;
  previous[x][y+2][2] = b;


}

void generate2DNoise(){
  float increment = 0.02;
  float xoff = 0.0; // Start xoff at 0
  float detail = map(mouseX, 0, width, 0.1, 0.6);
  noiseDetail(8, detail);
  
  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  for (int x = 0; x < width; x++) {
    xoff += increment;   // Increment xoff 
    float yoff = 0.0;   // For every xoff, start yoff at 0
    for (int y = 0; y < height; y++) {
      yoff += increment; // Increment yoff
      
      // Calculate noise and scale by 255
      float bright = noise(xoff, yoff) * 255;

      // Try using this line instead
      //float bright = random(0,255);
      
      // Set each pixel onscreen to a grayscale value
      // noise[x+y*width] = color(bright);
      noise[x][y] = bright;
    }
  }
}

 void rippleClassic() {
   if (millis() - timer >= 6000) {
     // randomRipple();
     timer = millis();
   }
   background(0);
   loadPixels();
   for (int i = 1; i < cols-1; i++) {
     for (int j = 1; j < rows-1; j++) {
       current[i][j][0] = (
         previous[i-1][j][0] + 
         previous[i+1][j][0] +
         previous[i][j-1][0] + 
         previous[i][j+1][0]) / 2 - current[i][j][0];
       current[i][j][0] = current[i][j][0] * dampening;
       int index = i + j * cols;
       pixels[index] = color(current[i][j][0]);
     }
   }
   updatePixels();

   float[][][] temp = previous;
   previous = current;
   current = temp;
 }
 
void rippleColor() {
   if (millis() - timer >= 6000) {
     // randomRipple();
     timer = millis();
   }
   background(0);
  loadPixels();
  for (int i = 1; i < cols-1; i++) {
    for (int j = 1; j < rows-1; j++) {

      float colorScaler = 0.5;
      float noiseScale = 0.08;
      float currentRed = (
        previous[i-1][j][0] + 
        previous[i+1][j][0] +
        previous[i][j-1][0] + 
        previous[i][j+1][0]) * colorScaler - current[i][j][0];
      currentRed = currentRed * dampening;
      currentRed = currentRed - noiseScale * noise[i][j];
      current[i][j][0] = currentRed;

     float currentGreen = (
        previous[i-1][j][1] + 
        previous[i+1][j][1] +
        previous[i][j-1][1] + 
        previous[i][j+1][1]) * colorScaler - current[i][j][1];
      currentGreen = currentGreen * dampening;
      currentGreen = currentGreen - noiseScale * noise[i][j];
      current[i][j][1] = currentGreen;

      float currentBlue = (
        previous[i-1][j][2] + 
        previous[i+1][j][2] +
        previous[i][j-1][2] + 
        previous[i][j+1][2]) * colorScaler - current[i][j][2];
      currentBlue = currentBlue * dampening;
      currentBlue = currentBlue - noiseScale * noise[i][j];
      current[i][j][2] = currentBlue;
      
      color currentColor = color(currentRed, currentGreen, currentBlue);
      
      int index = i + j * cols;
      pixels[index] = currentColor;
    }
  }
  updatePixels();

  float[][][] temp = previous;
  previous = current;
  current = temp;
 }
 
 

// color experiment
void coloAsciiRipples() {
  //if (millis() - timer >= 2000) {
  //  randomRipple();
  //  timer = millis();
  //}
  background(0);
  PImage frame = createImage(width, height, ARGB);
  loadPixels();
  for (int i = 1; i < cols-1; i++) {
    for (int j = 1; j < rows-1; j++) {

      float colorScaler = 0.5;
      float noiseScale = 0.08;
      float currentRed = (
        previous[i-1][j][0] + 
        previous[i+1][j][0] +
        previous[i][j-1][0] + 
        previous[i][j+1][0]) * colorScaler - current[i][j][0];
      currentRed = currentRed * dampening;
      currentRed = currentRed - noiseScale * noise[i][j];
      current[i][j][0] = currentRed;

     float currentGreen = (
        previous[i-1][j][1] + 
        previous[i+1][j][1] +
        previous[i][j-1][1] + 
        previous[i][j+1][1]) * colorScaler - current[i][j][1];
      currentGreen = currentGreen * dampening;
      currentGreen = currentGreen - noiseScale * noise[i][j];
      current[i][j][1] = currentGreen;

      float currentBlue = (
        previous[i-1][j][2] + 
        previous[i+1][j][2] +
        previous[i][j-1][2] + 
        previous[i][j+1][2]) * colorScaler - current[i][j][2];
      currentBlue = currentBlue * dampening;
      currentBlue = currentBlue - noiseScale * noise[i][j];
      current[i][j][2] = currentBlue;
      
      color currentColor = color(currentRed, currentGreen, currentBlue);
      
      int index = i + j * cols;
      frame.pixels[index] = currentColor;
      pixels[index] = currentColor;
      
      
    }
  }
  updatePixels();

  float[][][] temp = previous;
  previous = current;
  current = temp;


  frame.resize(int(width/ fontSize), int(height / fontSize));
  background(0);
  pushMatrix();
  int index = 0;
  for (int y = 1; y < frame.height; y++) {
    // Move down for next line
    translate(0, fontSize);
    pushMatrix();
    for (int x = 0; x < frame.width; x++) {

      int pixelColor = frame.pixels[index];
      // Faster method of calculating r, g, b than red(), green(), blue() 
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      int pixelBright = max(r, g, b);
      float diff = pixelBright - bright[index];
      bright[index] += diff * brightDamp;

      if(greyScale){pixelColor = color(pixelBright,pixelBright,pixelBright); }
      fill(int(pixelColor*pixelOffset));
      int letterIndex = int(bright[index]);
      letterIndex = Math.max(0, Math.min(int(letterIndex * letterIndexScale), (letters.length - 1))); 
      
 
      char curLetter = letters[letterIndex];
      //println("current letter: ", curLetter);
      
      
      if(addInverseLetters){
        if(letterIndex > 128){
          // draw a box with the current pixel color
          rect(0,0,10,10);
          //change the fill color to black for the text
          fill(0);
          
        }
      }
      
      text(curLetter, 0, 0);
      index++;
      translate(fontSize, 0);
    }
    popMatrix();
  }
  popMatrix();
  // videoExport.saveFrame();
}


void draw(){
  if(displayMode == 0) {rippleClassic();}
  if(displayMode == 1) {rippleColor();}
  if(displayMode == 2) {coloAsciiRipples();}
}
