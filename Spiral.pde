class Spiral implements Scene {
  float spiralRadius;
  float avgFreqVolume;
  float spiralAng;
  float rotateSpeed;
  boolean isRising;
  float lastRiseDetectionTime;
  float highVol;
  float lastHighVol;
  int numIncreases;
  
  Spiral() {
    avgFreqVolume = 0;
    spiralRadius = width/6;
    spiralAng = 0;
    rotateSpeed = PI/48;
    isRising = false;
    highVol = 0;
    numIncreases = 0;
  }
  
  void update() {
    updateSpiralSize(fft.getFreq(14000));
    detectRising();
  }
  
  void show() {
    drawSpiral();
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
  
  void drawSpiral() {
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
}
