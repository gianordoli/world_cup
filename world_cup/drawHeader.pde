void drawHeader() {
  fill(255);
  textFont(archivoNarrow);
  textSize(42);
  textAlign(LEFT, TOP);
  PVector textPos = new PVector(18, 26);
  String msg = "Copa da Europa?";
  text(msg, textPos.x, textPos.y);

  textPos.y = 75;
  textFont(bitter);
  textSize(14);
  textLeading(17);
  msg = "Três em cada quatro convocados jogam em clubes europeus; veja de quais países eles saem para atuar em suas seleções e quais são os esquadrões com menos atletas jogando em casa";
  text(msg, textPos.x, textPos.y, 270, 200);
  
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
}
