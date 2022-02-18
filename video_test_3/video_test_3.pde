/**
 * ASCII Video
 * Based on Sketch by Ben Fry. 
 
 */
import processing.video.*;
import com.hamoid.*;
VideoExport videoExport;
Movie video;
boolean cheatScreen;

// All ASCII characters, sorted according to their visual density
//String letterOrder = " .`-_':,;^=+/\"|)\\<>)iv%xclrs{*}I?!][1taeo7zjLunT#JCwfy325Fp6mqSghVd4EgXPGZbYkOA&8U$@KHDBWNMR0Q";
//String letterOrder = "Q0RMNWBDHK@$U8&AOkYbZGPXgE4dVhgSqm6pF523yfwCJ#TnuLjz7oeat1[]!?I}*{srlcx%vi)><\\)|\"/+=^;," ;

//String letterOrder = "█▓▒░▀▀▄▒░¬!?)><\\)|\"/+=^;,:'_-`. ";

//String letterOrder = "▓▒░◿◺◹◸◡◠◟◞◝◜◗◖▱▰▯▮▭▬▫▪▩╬╫╪╩╨╧╦╥╤╣╢╡╠╟╞╝╜╛╚╙╘╗╖╕╔╓╒║═▟▞▝▜▛▚▙▘▗▖█▇▆▅▄▃▂▁▀▀▄█░¬!?=`*+◠◜_⋰░▃▂▁/;:.⨯⨉✖✕×   ";
String letterOrder = "▓▒░◿◺◹◸◡◠◟◞◝◜◗◖▱▰▯▮▭▬▫▪▩╬╫╪╩╨╧╦╥╤╣╢╡╠╟╞╝╜╛╚╙╘╗╖╕╔╓╒║═▟▞▝▜▛▚▙▘▗▖█▇▆▅▄▃▂▁▀▀▄█░¬!?=`*+◠◜_⋰░▃▂▁/;:'_-`.  ";

char[] letters;

float[] bright;
char[] chars;

PFont font;
//float fontSize = 1.5;
float fontSize = 10.0;



int videoWidth = 720;
int videoHeight = 720;
int curFrame = 0;

void setup() {
  size(720, 720);

  //TODO: Make this relative for parent directory
  //String dp=sketchPath();
  //video = new Movie(this, dp + "test.mov");
  //video = new Movie(this, "test.mov");
  video = new Movie(this, "test-bw-5-2x.mp4");  
  video.play();  
  //video.loop();  
  
  // Todo why doesn't video load?
  //int count = video.width * video.height;
  // set global vars at top for convenience now: videoHeight / videoWidth
  int count = int(videoWidth * videoHeight / fontSize);

  font = loadFont("C64ProMono-10.vlw");

  // for the 256 levels of brightness, distribute the letters across
  // the an array of 256 elements to use for the lookup
  letters = new char[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }

  // current characters for each position in the video
  chars = new char[count];

  // current brightness for each point
  bright = new float[count];
  for (int i = 0; i < count; i++) {
    // set each brightness at the midpoint to start
    bright[i] = 128;
  }
  
  
  videoExport = new VideoExport(this, "myVideo.mp4");
  videoExport.setFrameRate(30);  
  videoExport.startMovie();
  delay(1000);
  
}

void movieEvent(Movie m) {
  m.read();
}

//void captureEvent(Capture c) {
//  c.read();
//}


void draw() {
  background(0);

  pushMatrix();

  // TODO: Again, no video width
  //float hgap = width / float(video.width);
  //float vgap = height / float(video.height);
  float hgap = width / float(videoWidth);
  float vgap = height / float(videoHeight);

  float scaleFactor = max(hgap, vgap) / fontSize;
  //println("scale factor: ", scaleFactor);
  //println("rev scale factor: ", revScaleFactor);
  textFont(font, fontSize);

  int index = 0;
  video.loadPixels();
  PImage frame = createImage(videoWidth, videoHeight, ARGB);
  frame.pixels = video.pixels; 
  frame.resize(int(videoWidth/fontSize), int(videoHeight / fontSize));
  
  //println("video pixels length: ", video.pixels.length);
  //println("frame pixels length: ", frame.pixels.length);
  
  curFrame++;
  if(curFrame % 100 == 0){println("current frame: ", curFrame);}
  
  
  //String testString = "A";
  //println("current text width: ", textWidth(testString));
  
  for (int y = 1; y < frame.width; y++) {
    // Move down for next line
    translate(0, fontSize);
    pushMatrix();
    for (int x = 0; x < frame.height; x++) {
      if(frame.pixels.length == 0){
        break;
      }   
      
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

      // The 0.1 value is used to damp the changes so that letters flicker less
      float diff = pixelBright - bright[index];
      bright[index] += diff * 0.1;

      //fill(pixelColor);
      fill(int(pixelColor*1.3));
      int letterIndex = int(bright[index]);
      
      
      //here there be dragons
      float liScale = 1.05;
      letterIndex = Math.max(0, Math.min(int(letterIndex * liScale), (letters.length - 1))); 
      
      
      char curLetter = letters[letterIndex];
      //println("current letter: ", curLetter);
      text(curLetter, 0, 0);
      
      // Move to the next pixel
      index++;

      // Move over for next character
      //translate(1.0 / fontSize, 0);
      translate(fontSize, 0);
    }
    popMatrix();
  }
  popMatrix();
  
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
  println("key pressed: ", key);
  switch (key) {
    case 'g': saveFrame(); break;
    case 'c': cheatScreen = !cheatScreen; break;
    case 'f': fontSize *= 1.1; break;
    case 'F': fontSize *= 0.9; break;
    case 'q': { videoExport.endMovie(); exit();}
  }
}
