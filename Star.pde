class Star implements Scene {
  int starX;
  int starY;
  int deltaX;
  int deltaY;
  float starSize;
  
  Star() {
    starX = width/2;
    starY = width/2;
    deltaX = 1;
    deltaY = 1;
  }
  
  void update() {
    updateStarSize(fft.getFreq(60));
  }
  
  void show() {
    drawStar(starX, starY, starSize, volume*levelScale);
    drawStar(starX, starY, starSize*1.2, volume*levelScale);
  }
  
  void updateStarPosition() {
  if (starX - starSize <= 0 || starX + starSize >= width) {
    deltaX = deltaX*-1;
  } 
  if (starY - starSize <= 0 || starY + starSize >= height) {
    deltaY = deltaY*-1;
  }
  starX += deltaX;
  starY += deltaY;
  }
  
  void updateStarSize(float freq) {
    starSize = freq*0.5+height/6;
  }
  
  void randomMoveStar() {
    starX = int(random(starSize, width-starSize));
    starY = int(random(starSize, height-starSize));
  }
  
  void drawStar(float x, float y, float size, float degree) {
    pushMatrix();
    translate(x, y);
    for (int i = 0; i < 4*degree; i++) {
      pushMatrix();
      rotate(i*PI/2/degree);
      drawSpike(size, degree);
      popMatrix();
      pushMatrix();
      scale(1, -1);
      rotate(i*PI/2/degree);
      drawSpike(size, degree);
      popMatrix();
    }
    popMatrix();
  }
  
  void drawSpike(float size, float degree) {
    strokeWeight(1);
    beginShape();
    vertex(0, 0);
    drawVertex(size/2, PI/4, degree);
    drawVertex(size*5/12, 5*PI/16, degree);
    drawVertex(size*2/3, 3*PI/8, degree);
    drawVertex(size*7/12, 7*PI/16, degree);
    drawVertex(size, PI/2, degree);
    endShape(CLOSE);
  }
  
  void drawVertex(float size, float angle, float degree) {
    vertex(size*cos(angle/degree), size*sin(angle/degree));
  }
}
