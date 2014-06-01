void drawLabels(){
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(54);
  text("32", 354, 42);
  textFont(archivoNarrowBold);
  textSize(13);
  text("SELEÇÕES", 354, 82);
  
  noFill();
  stroke(255);
  strokeWeight(1);  
  arc(390, 75, 50, 50, -PI/2, 0);
  line(415, 75, 420, 70);
  line(415, 75, 410, 70);  
  

  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(30);
  text("145", 290, 350);
  textFont(archivoNarrowBold);
  textSize(11);
  text("CLUBES DE", 290, 375);
  textFont(bitterBold);
  textSize(52);
  text("53", 290, 395);
  textFont(archivoNarrowBold);
  textSize(19);
  text("PAÍSES", 288, 435);
  
  stroke(255);
  strokeWeight(1);
  line(320, 395, 340, 395);
  line(340, 395, 335, 390);
  line(340, 395, 335, 400);
  
//  pushMatrix();
//    translate(center.x, center.y);
//    float increment = 0.8*PI/4
//    for(int angle = 0.2)
////    arc(0, 0, 680, 680, 0, PI);
//  popMatrix();
}
