import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;
Movie video;

String piString;
int columns = 720;
int rows = 720;
int row = 0;
color[] colors = new color[10];


void setup() {
  size(720, 720);
  frameRate(60);
  noSmooth();
  noStroke();
  background(32);
  PFont myFont = loadFont("C64ProMono-10.vlw");
  //myFont = createFont("data/Comfortaa-Regular.ttf", 40);
  textFont(myFont);

  //colors = [
  //  "black", //0
  //  "red", //1
  //  "orange", //2
  //  "yellow", //3
  //  "green", //4
  //  "cyan", // 5
  //  "blue", //6
  //  "indigo", //7
  //  "violet", //8
  //  "white", //9
  //];
  
  //colors[0] = color(236, 166, 15);
  //colors[1] = color(232, 125, 27);
  //colors[2] = color(227, 45, 42);
  //colors[3] = color(210, 0, 64);
  //colors[4] = color(168, 11, 95);
  //colors[5] = color(135, 46, 134);
  //colors[6] = color(91, 77, 163);
  //colors[7] = color(46, 116, 157);
  //colors[8] = color(30, 154, 119);
  //colors[9] = color(91, 176, 90);
  
  colors[0] = color(255, 0, 0);  //r 
  colors[1] = color(255, 80, 0); //o
  colors[2] = color(255, 255, 0); //y
  colors[3] = color(0, 255, 0); //g
  colors[4] = color(0, 255, 255); //b
  colors[5] = color(0, 0, 255); //i
  colors[6] = color(255, 0, 255);  // v
  colors[7] = color(80,80,80); //gray
  colors[8] = color(0, 0, 0); // black
  colors[9] = color(255, 255, 255); // white
  
  piString = loadStrings("pi.txt")[0];
  background(255);
  
    //String exportFolder = sketchPath().getParent();
  videoExport = new VideoExport(this, "myVideo.mp4");
  videoExport.setFrameRate(30);  
  videoExport.startMovie();
  delay(1000);
}

// restart the animation with random colors
void keyPressed() {
  //colors = [];
  //for (let i = 0; i < 10; i++) {
  //  //colors.push(map(i, 0, 9, 0, 255));
  //  colors.push(color(random(255), random(255), random(255)));
  //}
  //background(0);
  //row = 0;
  //loop();
}

void draw() {

  // draw 
  for (int column = 0; column < columns; column++) {
    int piDigitIndex = columns * row + column;
    int piDigit = int(piString.substring(piDigitIndex, piDigitIndex + 1));
    color digitColor = colors[piDigit];

    fill(digitColor);
    rect(column, row, 1, 1);
  }

  // move to the next row, or stop the animation
  videoExport.saveFrame();
  row++;
  if (row >= rows) {
    noLoop();
  }
}
