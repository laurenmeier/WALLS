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

Pyramid pyramidScene;
Twinkle twinkleScene;
Star starScene;
Spiral spiralScene;

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
  
  pyramidScene = new Pyramid();
  twinkleScene = new Twinkle();
  starScene = new Star();
  spiralScene = new Spiral();
}

void draw()
{
  background(0);
  stroke(255);
  noFill(); 

  fft.forward(input_audio.mix);
  beat.detect(input_audio.mix);
  
  
  pyramidScene.update();
  updateVolume();
  twinkleScene.update();
  starScene.update();
  spiralScene.update();
  
  // determine the scene to be drawn
  if (beat.isOnset()) {
    if (pyramidScene.isWallsPresent) {
      sceneSelect = SceneSelector.PYRAMID;
    }
  }

  if (!pyramidScene.isWallsPresent) {
    if (spiralScene.isRising) {
      sceneSelect = SceneSelector.SPIRAL;
    } else if (volume > 0.4) {
      if (sceneSelect != SceneSelector.STAR) starScene.randomMoveStar();
      sceneSelect = SceneSelector.STAR;
    }
  } 
  
  // draw riser background
  if (sceneSelect != SceneSelector.SPIRAL) twinkleScene.show();
  
  // draw current selected scene
  switch (sceneSelect) {
    case SPIRAL:
      spiralScene.show();
      break;
    case PYRAMID:
      pyramidScene.show();
      break;
    case STAR:
      starScene.updateStarPosition();
      if (volume < 0.3) starScene.randomMoveStar();
      starScene.show();
      break;
  }
}

void updateVolume() {
  if (millis() % 50 == 0) lastVolume = volume;
  volume = input_audio.mix.level();
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
}
