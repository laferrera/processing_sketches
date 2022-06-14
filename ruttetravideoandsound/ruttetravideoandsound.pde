//Christian Attard
//2015 @ introwerks 

//Pierre Puentes
//2016 @ DRLZTN

//Libraries
import processing.video.*;
Capture video;                     
Movie movie;          
PImage frame;

import controlP5.*;
ControlP5 cp5;

//import spout.*;
//Spout spout;

import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioInput in;                    
AudioPlayer song;                 
BeatDetect beat;                  
BeatListener bl;

// Image

PImage img;
String name = "aster";          
String type = "png";             
int count = int(random(666));
color col;
int c;
int curFrame = 0;
// Parameters

int musicMode = 1;
// 0 -> No Music
// 1 -> Sound File
// 2 -> Microphone
int imageMode = 2;
// 0 -> Image File
// 1 -> Video File
// 2 -> Camera

float space = 5.0;                     // Space between lines
float weight = 2.0;                  // Line weight
float zoom = 1;                      // Zoom image
int translatex = 0;                // translate the image if necesary
int translatey = 0;
float depthZ;                      // Depth
float depth = 1.0;                 // Max value for slider

float kickSize;                    // Sound Kick variable

PGraphics pgr;                     // Spout graphics 

// BeatListener Class
class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

void setup() {

  size(720, 720, P3D);
  pgr = createGraphics(640, 480, P3D);
  //smooth();

  // Working with external cámeras
  String[] cameras = Capture.list();            
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }

  // Working with image file
  img = loadImage(name + "." + type);         

  // Working with Camera
  video = new Capture(this, cameras[0]);
  if (imageMode==2) {
    video.start();
  }
  
  // Working with video file
  movie = new Movie(this, "a-letter.mp4");
  movie.loop();
  
  // Depth control slider
  cp5 = new ControlP5(this);
  cp5.addSlider("depth")
    .setRange(0.0, 1)
    .setValue(0.0)
    .setPosition(20, height-30)
    .setSize(100, 10)
    ;
  cp5.setAutoDraw(false);
  
  
  cp5.addSlider("space")
    .setRange(2.0, 10.0)
    .setValue(5.0)
    .setPosition(20, height-20)
    .setSize(100, 10)
    ;
  cp5.setAutoDraw(false);
  
  cp5.addSlider("weight")
    .setRange(1.0, 10.0)
    .setValue(2.0)
    .setPosition(20, height-10)
    .setSize(100, 10)
    ;
  cp5.setAutoDraw(false);
  

  // Spout object and sender
  //spout = new Spout(this);
  //spout.createSender("Rutt");

  // Minim object and input
  minim = new Minim(this);
  // Microphone
  in = minim.getLineIn(1); 
  // Sound File
  //song = minim.loadFile("Designer Drugs - Future Body.mp3", 2048);                                                 // Play song if you hit P
  song = minim.loadFile("get-up-short.wav", 2048);                                                 // Play song if you hit P

  // Beat detection
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());      
  beat.setSensitivity(10);                                          

  /* INFO FROM THE MINIM LIBRARIE EXAMPLE
   
   Set the sensitivity to 50 milliseconds
   After a beat has been detected, the algorithm will wait for 50 milliseconds 
   before allowing another beat to be reported. You can use this to dampen the 
   algorithm if it is giving too many false-positives. The default value is 10, 
   which is essentially no damping. If you try to set the sensitivity to a negative value, 
   an error will be reported and it will be set to 10 instead. 
   note that what sensitivity you choose will depend a lot on what kind of audio 
   you are analyzing. in this example, we use the same BeatDetect object for 
   detecting kick, snare, and hat, but that this sensitivity is not especially great
   for detecting snare reliably (though it's also possible that the range of frequencies
   used by the isSnare method are not appropriate for the song).
   
   */

  // Kick size and what analyses
  kickSize = 0.1;
  bl = new BeatListener(beat, song);
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {

  // New size for the kick variable
  if ( beat.isKick() ) kickSize = 0.7;                      
  kickSize = constrain(kickSize * 0.95, 0.1, 0.7);

  // Changes depth depending on musicMode
  switch(musicMode) {
  case 0:
    depthZ=depth;
    break;
  case 1:
    song.play();
    depthZ=depth+kickSize;
    break;
  case 2:
    depthZ=depth+in.right.get(1);
    break;
  }

  // Changes the image source depending on imageMode
  switch(imageMode) {
  case 0:
    pushMatrix();
    background(0);
    translate(translatex, translatey);
    for (int i = 0; i < img.width; i+=space) {            // You can change video. to img. or movie.
      beginShape();
      for (int j = 0; j < img.height; j+=space) {
        c = i+(j*img.width);
        col = img.pixels[c];
        stroke(red(col), green(col), blue(col), 255);
        strokeWeight(weight);
        noFill();
        vertex (i, j, (depthZ * brightness(col))-zoom);
      }
      endShape();
    }
    popMatrix();
    break;
  case 1:
    curFrame++;
    pushMatrix();
    background(0);
    movie.loadPixels();
    image(movie,0,0,1,1);
    frame = createImage(movie.width, movie.height, ARGB);
    frame.pixels = movie.pixels;
    frame.resize(720,720);
    translate(translatex, translatey);
    for (int i = 0; i < frame.width; i+=space) {            // You can change video. to img. or movie.
      beginShape();
      for (int j = 0; j < frame.height; j+=space) {
        c = i+(j*frame.width);
        col = frame.pixels[c];
        stroke(red(col), green(col), blue(col), 255);
        strokeWeight(weight);
        noFill();
        vertex (i, j, (depthZ * brightness(col))-zoom);
      }
      endShape();
    }
    
    popMatrix();
    break;
  case 2:
    if (video.available()) {
      pushMatrix();
      background(0);
      video.read();                                             // reads and updates video file pixels
      video.loadPixels();
      image(video,0,0,1,1);
      frame = createImage(video.width, video.height, ARGB);
      frame.pixels = video.pixels;
      frame.resize(720,720);
      translate(translatex, translatey);
      for (int i = 0; i < frame.width; i+=space) {            // You can change video. to img. or movie.
        beginShape();
        for (int j = 0; j < frame.height; j+=space) {
          c = i+(j*frame.width);
          col = frame.pixels[c];
          stroke(red(col), green(col), blue(col), 255);
          strokeWeight(weight);
          noFill();
          vertex (i, j, (depthZ * brightness(col))-zoom);
        }
      endShape();
      }
    
      popMatrix();
    }
  }
  // Sends spout graphics
  //spout.sendTexture();
  
    // Slider
  gui();
}

// Slider function for working with 3D
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
}
