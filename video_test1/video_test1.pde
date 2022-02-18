import processing.video.*;

//https://forum.processing.org/two/discussion/6830/interpret-image-as-ascii-text.html
Movie video;
int videoScale = 10;
int cols, rows;
char[] ascii;

void setup() {
  size(720, 720);
  // Initialize columns and rows
  cols = width / videoScale;
  rows = height / videoScale;

  // Step 2. Initialize Movie object. The file "testmovie.mov" should live in the data folder.
  video = new Movie(this, "drop1.mov");

  // Step 3. Start playing movie. To play just once play() can be used instead.
  video.play();
}

// Step 4. Read new frames from the movie.
void movieEvent(Movie video) {
  video.read();
}

void draw() {
  background(0);
  video.loadPixels();
  print("video pixels length 1");
      print(video.pixels.length);
  // Begin loop for columns
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      // Where are you, pixel-wise?
      int x = i*videoScale;
      int y = j*videoScale;

//      // Reverse the column to mirro the image.
//      //int loc = (video.width - i - 1) + j * video.width;

      int loc = i + j;      
      print("location", loc);      
      print("video pixels length 2");
      print(video.pixels.length); //<>//
      //color c = video.pixels[loc];
//      // A rectangle's size is calculated as a function of the pixel’s brightness.
//      // A bright pixel is a large rectangle, and a dark pixel is a small one.
//      float sz = (brightness(c)/255) * videoScale;

//      rectMode(CENTER);
//      fill(255);
//      noStroke();
//      rect(x + videoScale/2, y + videoScale/2, sz, sz);
    }
  }
}

void asciify(PImage img) {
  // since the text is just black and white, converting the image
  // to grayscale seems a little more accurate when calculating brightness
  img.filter(GRAY);
  img.loadPixels();

  // grab the color of every nth pixel in the image
  // and replace it with the character of similar brightness
  for (int y = 0; y < img.height; y += rows) {
    for (int x = 0; x < img.width; x += rows) {
      color pixel = img.pixels[y * img.width + x];
      text(ascii[int(brightness(pixel))], x, y);
    }
  }
}
