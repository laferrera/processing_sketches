import oscP5.*;
import netP5.*;
import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;

int cols;
int rows;
float[][] current;// = new float[cols][rows];
float[][] previous;// = new float[cols][rows];
float dampening = .99;
int timer;
PFont font;
String letterOrder = "  .`-_':/;▁▂▃░⋰_◜◠+*`=?!¬░█▄▀▀▁▂▃▄▅▆▇█▖▗▘▙▚▛▜▝▞▟═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬▩▪▫▬▭▮▯▰▱◖◗◜◝◞◟◠◡◸◹◺◿░▒▓";
char[] letters;  
float fontSize = 12.0;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(720, 720);
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  oscP5 = new OscP5(this,10101);
  myRemoteLocation = new NetAddress("127.0.0.1",10102);

  font = loadFont("C64ProMono-10.vlw");
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
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
  c = color(255,0,0);
  previous[x][y] = c;
}

void draw() {
  if (millis() - timer >= 6000) {
    // randomRipple();
    timer = millis();
  }


  background(0);
  loadPixels();
  for (int i = 1; i < cols-1; i++) {
    for (int j = 1; j < rows-1; j++) {
      current[i][j] = (
        previous[i-1][j] + 
        previous[i+1][j] +
        previous[i][j-1] + 
        previous[i][j+1]) / 2 - current[i][j];
      current[i][j] = current[i][j] * dampening;
      int index = i + j * cols;
      pixels[index] = color(current[i][j]);
    }
  }
  updatePixels();

  float[][] temp = previous;
  previous = current;
  current = temp;
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