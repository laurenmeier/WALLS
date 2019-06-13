import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer input_audio;
FFT fft;
BeatDetect beat;

SceneSelector sceneSelect;
float lastVolume;
float volume;
int levelScale;

//line scene variables
float lineLength;
int direction;
int numLines;
boolean isWallsPresent;
float lastDetectionTime;
int wallTime;
float wallThickness;

//riser variables
float numStars;

//star variables
Star starScene;

//spiral variables
float spiralRadius;
float avgFreqVolume;
float spiralAng;
float rotateSpeed;
boolean isRising;
float lastRiseDetectionTime;
float highVol;
float lastHighVol;
int numIncreases;

void setup()
{
  fullScreen(P3D);
  
  minim = new Minim(this);

  input_audio = minim.loadFile("in her hands forever.mp3", 1024);
  input_audio.loop();
  
  // create an FFT object that has a time-domain buffer 
  // the same size as the input audio's sample buffer
  // the size of the spectrum will be half as large as the buffer size
  fft = new FFT(input_audio.bufferSize(), input_audio.sampleRate());
  beat = new BeatDetect();
  
  //general setup
  sceneSelect = SceneSelector.STAR;
  volume = 0;
  levelScale = 15;
  
  //line setup
  lineLength = height/10;
  direction = -1;
  numLines = 10;
  isWallsPresent = false;
  lastDetectionTime = 0;
  wallTime = 500;
  wallThickness = 0.8;
  
  //star setup
  starScene = new Star();

  //spiral setup
  avgFreqVolume = 0;
  spiralRadius = width/6;
  spiralAng = 0;
  rotateSpeed = PI/48;
  isRising = false;
  highVol = 0;
  numIncreases = 0;
}

void draw()
{
  background(0);
  stroke(255);
  noFill(); 

  fft.forward(input_audio.mix);
  beat.detect(input_audio.mix);
  // update pyramid scene levels
  detectWalls();
  updateVolume();
  // update riser levels
  updateNumStars(fft.getFreq(8000));
  // update star scene levels
  starScene.update();
  updateSpiralSize(fft.getFreq(14000));
  detectRising();
  
  // determine the scene to be drawn
  // select the pyramid scene if walls are deteced iff song is on a beat
  if (beat.isOnset()) {
    if (isWallsPresent) {
      sceneSelect = SceneSelector.PYRAMID;
    }
  }
  // select the star scene at any time if walls are not deteced
  if (!isWallsPresent) {
    if (isRising) {
      sceneSelect = SceneSelector.SPIRAL;
    } else if (volume > 0.4) {
      if (sceneSelect != SceneSelector.STAR) starScene.randomMoveStar();
      sceneSelect = SceneSelector.STAR;
    }
  } 
  
  // draw riser background
  if (sceneSelect != SceneSelector.SPIRAL) riser();
  
  // draw current selected scene
  switch (sceneSelect) {
    case SPIRAL:
      spiral();
      break;
    case PYRAMID:
      pyramid();
      break;
    case STAR:
      starScene.updateStarPosition();
      if (volume < 0.3) starScene.randomMoveStar();
      starScene.show();
      break;
  }
  
  //for testing
  textSize(32);
  //float round = float(ceil(volume*100000))/100000;
  //text("sceneSelect: " + sceneSelect, 10, 30); 
  //text("avgFreqVolume: " + fft.getFreq(10000), 10, 80);
  //text("numFramesRising:" + numFramesRising, 10, 80);
}

void updateVolume() {
  if (millis() % 50 == 0) lastVolume = volume;
  volume = input_audio.mix.level();
}

void detectWalls() {
  if (abs(lastVolume - volume) > 0.3) {
    isWallsPresent = true;
    lastDetectionTime = millis();
  } else if (millis() - lastDetectionTime > wallTime) {
    isWallsPresent = false;
  }
}

void detectRising() {
  lastHighVol = highVol;
  highVol = fft.getFreq(8000);
  if (millis()%20 == 0) numIncreases = 0;
  if (isRising && millis() - lastRiseDetectionTime > 100) isRising = false;
  if (millis()%20 == 19 && numIncreases > 5) {
    isRising = true;
    lastRiseDetectionTime = millis();
  }
  if (highVol - lastHighVol > 0.05) numIncreases += 1;
}

void pyramid() {
  noFill();
  strokeWeight(pow(volume, 2)*levelScale*wallThickness);
  lineLength = lineLength + (0.5*direction);
  if (lineLength < 1 || lineLength > height/10) {
    direction = direction * -1;
  }
  translate(width/2.1, height/12);
  rotateZ(PI/4.23);
  for (int i = 0; i < numLines; i++) {
    float x = i*10;
    for (int n = 0; n < height; n+=lineLength+10) {
      line(x, n, x, n + lineLength, x, x);
    }
  }
}

void updateNumStars(float freq) {
  numStars = int(freq)*10;
}

void riser() {
  strokeWeight(1);
  for (int i = 0; i < numStars; i++) {
    float x = random(0, width);
    float y = random(0, height);
    float w = random(5, 15);
    drawDiamond(x, y, w, 2*w);
  }
}

//draw one diamond at the coordinates (x, y)
//w is the width of the diamond, h is the height
void drawDiamond(float x, float y, float w, float h) {
  float r = random(100, 200);
  float g = random(100, 200);
  float b = random(185, 255);
  fill(r, g, b);
  stroke(r, g, b);
  ellipse(x, y, w, h);
  fill(0);
  stroke(255);
  arc(x-w/2, y-h/2, w, h, 0, HALF_PI);
  arc(x+w/2, y-h/2, w, h, HALF_PI, PI);
  arc(x+w/2, y+h/2, w, h, PI, PI+HALF_PI);
  arc(x-w/2, y+h/2, w, h, PI+HALF_PI, 2*PI);
}

void updateSpiralSize(float freq) {
  float newAvg = (avgFreqVolume + freq) / frameCount;
  if (freq > 0.4 && spiralRadius > width/12) {
    spiralRadius = spiralRadius - 1;
  } else if (spiralRadius < width/2.5) {
    spiralRadius = spiralRadius + 1;
  }
  avgFreqVolume = newAvg;
  rotateSpeed = PI/768 + volume*0.2;
  spiralAng = spiralAng + rotateSpeed;
}

void spiral() {
  pushMatrix();
  drawBoxCylinder(10, spiralRadius, 0, 3);
  drawBoxCylinder(10, spiralRadius, PI, 3);
  popMatrix();
}

void drawBoxCylinder(float size, float radius, float startAng, float numRotations) {
  pushMatrix();
  translate(width/2, 0);
  rotateY(spiralAng);
  int numBoxes = int(height/size);
  for (int i = 0; i < numBoxes; i++) {
    pushMatrix();
    float angle = startAng + i*(numRotations*2*PI/numBoxes);
    translate(radius*cos(angle), i*size, radius*sin(angle));
    box(size);
    popMatrix();
  }
  popMatrix();
}

void keyPressed() {
  if ( key == 'f' )
  {
    // skip forward 1 second (1000 milliseconds)
    input_audio.skip(5000);
  }
  if ( key == 'r' )
  {
    // skip backward 1 second (1000 milliseconds)
    input_audio.skip(-5000);
  }
  if (key == 'm' ) {
    wallTime = wallTime + 100;
  }
  if (key == 'l' ) {
    wallTime = wallTime - 100;
  }
  if (key=='w') {
    wallThickness = wallThickness + 0.1;
  }
}
