class Pyramid implements Scene {
  float lineLength;
  int direction;
  int numLines;
  boolean isWallsPresent;
  float lastDetectionTime;
  int wallTime;
  float wallThickness;
  
  Pyramid() {
    lineLength = height/10;
    direction = -1;
    numLines = 10;
    isWallsPresent = false;
    lastDetectionTime = 0;
    wallTime = 500;
    wallThickness = 0.8;
  }
  
  void update() {
    detectWalls();
  }
  
  void show() {
    drawPyramid();
  }
  
  void detectWalls() {
    if (abs(lastVolume - volume) > 0.3) {
      isWallsPresent = true;
      lastDetectionTime = millis();
    } else if (millis() - lastDetectionTime > wallTime) {
      isWallsPresent = false;
    }
  }
  
  void drawPyramid() {
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
}
