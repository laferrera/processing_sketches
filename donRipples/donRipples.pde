import oscP5.*;
import netP5.*;
import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;
OscP5 oscP5;
NetAddress myRemoteLocation;

int cols;
int rows;
float[][] current;// = new float[cols][rows];
float[][] previous;// = new float[cols][rows];

// int[][] current;// = new float[cols][rows];
// int[][] previous;// = new float[cols][rows];

float dampening = .99;
int timer;
PFont font;
String letterOrder = "  .`-_':/;▁▂▃░⋰_◜◠+*`=?!¬░█▄▀▀▁▂▃▄▅▆▇█▖▗▘▙▚▛▜▝▞▟═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬▩▪▫▬▭▮▯▰▱◖◗◜◝◞◟◠◡◸◹◺◿░▒▓";
char[] letters;  
float fontSize = 12.0;

float[] bright;
float brightDamp = 0.1;
float pixelOffset = 1.0;
float letterIndexScale = 0.8;
Boolean greyScale = true;
Boolean addInverseLetters = true;

void setup() {
  size(720, 720);
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  // current = new int[cols][rows];
  // previous = new int[cols][rows];
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
}


void keyPressed() {
  switch (key) {
    case 'g': saveFrame(); break;
    // case 'c': cheatScreen = !cheatScreen; break;
    // case 'b': brightDamp *= 1.1; println("brightDamp: ", brightDamp);break;
    // case 'B': brightDamp *= 0.9; println("brightDamp: ", brightDamp);break;
    // case 'p': pixelOffset *= 1.1; println("pixelOffset: ", pixelOffset); break;
    // case 'P': pixelOffset *= 0.9; println("pixelOffset: ", pixelOffset); break;
    // case 'f': fontSize *= 1.1; break;
    // case 'F': fontSize *= 0.9; break;
    case 'q': { videoExport.endMovie(); exit();}
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
  startRipple(x, y, 5000);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  randomRipple();
}

void startRipple(int x,int y,int c){
  // previous[mouseX][mouseY] = color(255,0,0);
  int r = int(random(0, 255));
  int g = int(random(0, 255));
  int b = int(random(0, 255));
  color thisColor = color(r,g,b);
  // c = color(255,0,0);
  previous[x][y] = thisColor;
}

// void oldDraw() {
//   if (millis() - timer >= 6000) {
//     // randomRipple();
//     timer = millis();
//   }
//   background(0);
//   loadPixels();
//   for (int i = 1; i < cols-1; i++) {
//     for (int j = 1; j < rows-1; j++) {
//       current[i][j] = (
//         previous[i-1][j] + 
//         previous[i+1][j] +
//         previous[i][j-1] + 
//         previous[i][j+1]) / 2 - current[i][j];
//       current[i][j] = current[i][j] * dampening;
//       int index = i + j * cols;
//       pixels[index] = color(current[i][j]);
//     }
//   }
//   updatePixels();

//   float[][] temp = previous;
//   previous = current;
//   current = temp;
// }


// working with ascii
void draw() {
  if (millis() - timer >= 6000) {
    // randomRipple();
    timer = millis();
  }

  PImage frame = createImage(width, height, ARGB);
  loadPixels();
  dampening = 0.97;
  for (int i = 1; i < cols-1; i++) {
    for (int j = 1; j < rows-1; j++) {
      current[i][j] = (
        previous[i-1][j] + 
        previous[i+1][j] +
        previous[i][j-1] + 
        previous[i][j+1]) / 2 - current[i][j];
      current[i][j] = current[i][j] * dampening;
      int index = i + j * cols;
      frame.pixels[index] = color(current[i][j]);
      pixels[index] = color(current[i][j]);
    }
  }
  float[][] temp = previous;
  previous = current;
  current = temp;


  frame.resize(int(width/fontSize), int(height / fontSize));
  background(0);
    // updatePixels();
  pushMatrix();
  int index = 0;
 for (int y = 1; y < frame.width; y++) {
    // Move down for next line
    translate(0, fontSize);
    pushMatrix();
    for (int x = 0; x < frame.height; x++) {

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
      
      
      // if(addInverseLetters){
      //   if(letterIndex > 128){
      //     // draw a box with the current pixel color
      //     rect(0,0,10,10);
      //     //change the fill color to black for the text
      //     fill(0);
          
      //   }
      // }
      
      text(curLetter, 0, 0);
      index++;
      translate(fontSize, 0);
    }
    popMatrix();
  }
  popMatrix();
  // videoExport.saveFrame();
}




// color experiment
// void draw() {
//   if (millis() - timer >= 6000) {
//     // randomRipple();
//     timer = millis();
//   }
//   background(0);
//   loadPixels();
//   for (int i = 1; i < cols-1; i++) {
//     for (int j = 1; j < rows-1; j++) {


//       // current[i][j] = (
//       //   previous[i-1][j] + 
//       //   previous[i+1][j] +
//       //   previous[i][j-1] + 
//       //   previous[i][j+1]) / 2 - current[i][j];
//       // current[i][j] = current[i][j] * dampening;

//       float colorScaler = 0.5;
//       int currentRed = int((
//         red(previous[i-1][j]) + 
//         red(previous[i+1][j]) +
//         red(previous[i][j-1]) + 
//         red(previous[i][j+1])) * colorScaler - red(current[i][j]));
//       currentRed = int(currentRed * dampening);

//      int currentGreen = int((
//         green(previous[i-1][j]) + 
//         green(previous[i+1][j]) +
//         green(previous[i][j-1]) + 
//         green(previous[i][j+1])) * colorScaler - green(current[i][j]));
//       currentGreen = int(currentGreen * dampening);

//       int currentBlue = int((
//         blue(previous[i-1][j]) + 
//         blue(previous[i+1][j]) +
//         blue(previous[i][j-1]) + 
//         blue(previous[i][j+1])) * colorScaler - blue(current[i][j]));
//       currentBlue = int(currentBlue * dampening);
      
//       color currentColor = color(currentRed, currentGreen, currentBlue);
//       current[i][j] = currentColor;

//       int index = i + j * cols;
//       pixels[index] = currentColor;
      
//     }
//   }
//   updatePixels();

//   int[][] temp = previous;
//   previous = current;
//   current = temp;
// }