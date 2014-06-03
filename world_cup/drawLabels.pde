void drawLabels(){
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(54);
  text("32", 344, 48);
  textFont(archivoNarrowBold);
  textSize(13);
  text("SELEÇÕES", 344, 80);
  
  noFill();
  stroke(255);
  strokeWeight(1);  
  arc(380, 65, 50, 50, -PI/2, 0);
  line(405, 65, 410, 60);
  line(405, 65, 400, 60);  
  
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(30);
  text("354", 290, 350);
  textFont(archivoNarrowBold);
  textSize(11);
  text("CLUBES DE", 290, 373);
  textFont(bitterBold);
  textSize(52);
  text("53", 290, 400);
  textFont(archivoNarrowBold);
  textSize(19);
  text("PAÍSES", 288, 435);
  
  stroke(255);
  strokeWeight(1);
  line(320, 395, 340, 395);
  line(340, 395, 335, 390);
  line(340, 395, 335, 400);
}
