class Twinkle implements Scene {
  float numStars;
  
  Twinkle() {
  }
  
  void update() {
    updateNumStars(fft.getFreq(8000));
  }
  
  void show() {
    drawTwinkle();
  }
  
  void updateNumStars(float freq) {
    numStars = int(freq)*10;
  }
  
  void drawTwinkle() {
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
}
