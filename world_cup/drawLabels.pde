void drawLabels(){
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(54);
  text("32", 344, 42);
  textFont(archivoNarrowBold);
  textSize(13);
  text("SELEÇÕES", 344, 82);
  
  noFill();
  stroke(255);
  strokeWeight(1);  
  arc(380, 75, 50, 50, -PI/2, 0);
  line(405, 75, 410, 70);
  line(405, 75, 400, 70);  
  

  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(30);
  text("145", 280, 350);
  textFont(archivoNarrowBold);
  textSize(11);
  text("CLUBES DE", 280, 375);
  textFont(bitterBold);
  textSize(52);
  text("53", 280, 395);
  textFont(archivoNarrowBold);
  textSize(19);
  text("PAÍSES", 278, 435);
  
  stroke(255);
  strokeWeight(1);
  line(310, 395, 330, 395);
  line(330, 395, 325, 390);
  line(330, 395, 325, 400);
  
//  pushMatrix();
//    translate(center.x, center.y);
//    float increment = 0.8*PI/4
//    for(int angle = 0.2)
////    arc(0, 0, 680, 680, 0, PI);
//  popMatrix();
}
