/**
 * ASCII Video
 * Based on Sketch by Ben Fry. 
 
 */
import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;
Movie video;
PImage logo;
boolean cheatScreen;
int dimenson = 720;

// All ASCII characters, sorted according to their visual density
// String letterOrder = " .`-_':,;^=+/\"|)\\<>)iv%xclrs{*}I?!][1taeo7zjLunT#JCwfy325Fp6mqSghVd4EgXPGZbYkOA&8U$@KHDBWNMR0Q";
//String letterOrder = "Q0RMNWBDHK@$U8&AOkYbZGPXgE4dVhgSqm6pF523yfwCJ#TnuLjz7oeat1[]!?I}*{srlcx%vi)><\\)|\"/+=^;," ;

// String letterOrder = "█▓▒░▀▀▄▒░¬!?)><\\)|\"/+=^;,:'_-`. ";
// String letterOrder = "▓▒░◿◺◹◸◡◠◟◞◝◜◗◖▱▰▯▮▭▬▫▪▩╬╫╪╩╨╧╦╥╤╣╢╡╠╟╞╝╜╛╚╙╘╗╖╕╔╓╒║═▟▞▝▜▛▚▙▘▗▖█▇▆▅▄▃▂▁▀▀▄█░¬!?=`*+◠◜_⋰░▃▂▁/;:.⨯⨉✖✕×   ";
// String letterOrder = " .▁▂▃▄▅▆▇█▇▆";
String letterOrder = " .▁▂▃▄▅▆▇█▇▆▅▄▃▂▁_";


char[] letters;
float[] bright;
char[] logoChars;
int[] logoCharsLetterIndices;
int[] animateLogoCharsLetterIndices;
char[] chars;

PFont font;

float fontSize = 12.0;
float brightDamp = 0.1;
float pixelOffset = 1.0;
float letterIndexScale = 0.8;
Boolean greyScale = true;
Boolean addInverseLetters = false;

int videoWidth = dimenson;
int videoHeight = dimenson;
int curFrame = 0;
 
int[] curPos = {0,0};
int curDirection = 1;
float probablity = 0.55f;
int rateOfChange = 4;

void setup() {
  size(720, 720);
  frameRate(60);
  logo = loadImage("ampamp-clear.png");
  int count = int(videoWidth * videoHeight / fontSize);
  font = loadFont("C64ProMono-10.vlw");
  if(addInverseLetters){letterOrder = letterOrder + letterOrder;}

  // for the 256 levels of brightness, distribute the letters across
  // the an array of 256 elements to use for the lookup
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }

  chars = new char[count];
  logoChars = new char[count];
  logoCharsLetterIndices = new int[count];
  animateLogoCharsLetterIndices = new int[count];
  // current brightness for each point
  bright = new float[count];
  for (int i = 0; i < count; i++) {
    // set each brightness to black
    bright[i] = 0;
  }
  
  //String exportFolder = sketchPath().getParent();
  videoExport = new VideoExport(this, "myVideo.mp4");
  videoExport.setFrameRate(60);  
  videoExport.startMovie();
  pixelateTheLogo();
  delay(1000);
  
}

void movieEvent(Movie m) {
  m.read();
}


void pixelateTheLogo(){
  logo.loadPixels();
  logo.resize(dimenson,dimenson);
  filter(INVERT);
  PImage frame = createImage(videoWidth, videoHeight, ARGB);
  frame.pixels = logo.pixels; 
  frame.resize(int(videoWidth/fontSize), int(videoHeight / fontSize));
  curPos[0] = frame.width;
  curPos[1] = frame.height;
  int index = 0;
  pushMatrix();
  for (int y = 1; y < frame.width; y++) {
    // Move down for next line
    translate(0, fontSize);
    pushMatrix();
    for (int x = 0; x < frame.height; x++) {
      if(frame.pixels.length == 0){ break; }
      int pixelColor = frame.pixels[index];
      // Faster method of calculating r, g, b than red(), green(), blue() 
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      // Another option would be to properly calculate brightness as luminance:
      // luminance = 0.3*red + 0.59*green + 0.11*blue
      // Or you could instead red + green + blue, and make the the values[] array
      // 256*3 elements long instead of just 256.
      int pixelBright = max(r, g, b);
      int letterIndex = int(pixelBright);
      letterIndex = Math.max(0, Math.min(int(letterIndex * letterIndexScale), (letters.length - 1))); 
      char curLetter = letters[letterIndex];
      logoChars[index] = curLetter;
      bright[index] = letterIndex;
      logoCharsLetterIndices[index] = letterIndex;
      animateLogoCharsLetterIndices[index] = letterIndex;
      text(curLetter, 0, 0);
      index++;
      translate(fontSize, 0);
    }
    popMatrix();
  }
  popMatrix();
}


void draw() {
  background(0);
  background(#3F3F3F);
  fill(255);
  fill(#EFEFEF);
  pushMatrix();
  textFont(font, fontSize);

  int index = 0;
  curFrame++;
  if(curFrame % 100 == 0){
    println("current frame: ", curFrame);
    println("current position: ", curPos[0], curPos[1]);
  }
  
  int resizedHeight = int(videoHeight / fontSize);
  int resizedWidth = int(videoWidth / fontSize);

  if(curDirection == 1){
    curPos[0] = curPos[0] - 1;
    curPos[1] = curPos[1] - 1;
  } else {
    curPos[0] = curPos[0] + 1;
    curPos[1] = curPos[1] + 1;
  }

  Boolean changedSomeLetters = false;

  for (int y = 1; y < resizedWidth; y++) {
    // Move down for next line
    translate(0, fontSize);
    pushMatrix();
    for (int x = 0; x < resizedHeight; x++) {
      int letterIndex = animateLogoCharsLetterIndices[index];
      char curLetter = letters[letterIndex];
      float random = random(0, 1);
      if( curDirection == 1 && curPos[0] < x && curPos[1] < y && logoCharsLetterIndices[index] != 0 && random < probablity ){
          if(letterIndex != 0 ){
            changedSomeLetters = true;
            letterIndex = letterIndex - rateOfChange;
            letterIndex = Math.max(0, letterIndex);
          }
      } 
      if( curDirection == -1 && curPos[0] > x && curPos[1] > y && logoCharsLetterIndices[index] != 0 && random < probablity ){
          if (letterIndex < letters.length - 1 && letterIndex < logoCharsLetterIndices[index] + rateOfChange){
            changedSomeLetters = true;
            letterIndex = letterIndex + rateOfChange;
            letterIndex = Math.min(letterIndex, letters.length - 1);
          }
      }
      animateLogoCharsLetterIndices[index] = letterIndex;
      curLetter = letters[letterIndex];

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
  if(!changedSomeLetters && (curPos[0] < 0 || curPos[0] > resizedWidth)){
    println("flipping direction");
    curDirection = -curDirection;
    if(curDirection == 1){
      curPos[0] = resizedWidth;
      curPos[1] = resizedHeight;
    } else {
      curPos[0] = 0;
      curPos[1] = 0;
      // clear out any stagglers if we just cleared the screen
      int count = int(videoWidth * videoHeight / fontSize);
      for (int i = 0; i < count; i++) {
        animateLogoCharsLetterIndices[i] = 0;
      }      
    }
  }


  videoExport.saveFrame();
  if (cheatScreen) {
    //image(video, 0, height - video.height);
    // set() is faster than image() when drawing untransformed images
    //set(0, height - video.height, video);
  }
}


/**
 * Handle key presses:
 * 'c' toggles the cheat screen that shows the original image in the corner
 * 'g' grabs an image and saves the frame to a tiff image
 * 'f' and 'F' increase and decrease the font size
 */
void keyPressed() {
  switch (key) {
    case 'g': saveFrame(); break;
    case 'c': cheatScreen = !cheatScreen; break;
    case 'b': brightDamp *= 1.1; println("brightDamp: ", brightDamp);break;
    case 'B': brightDamp *= 0.9; println("brightDamp: ", brightDamp);break;
    case 'p': pixelOffset *= 1.1; println("pixelOffset: ", pixelOffset); break;
    case 'P': pixelOffset *= 0.9; println("pixelOffset: ", pixelOffset); break;
    case 'f': fontSize *= 1.1; break;
    case 'F': fontSize *= 0.9; break;
    case 'q': { videoExport.endMovie(); exit();}
  }
}
