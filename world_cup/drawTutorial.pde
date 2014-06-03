void drawTutorial() {
  //Alpha layer
  fill(bgColor, 100);
  rect(0, 0, width, height);
  
  //Presets
  color tutorialColor = color(40, 200, 255);
  PVector textPos = new PVector(60, 50);
  PVector arrowPos = new PVector(0, 0);
  
  /*---------- FIRST SCREEN ----------*/
  fill(tutorialColor);
  textFont(archivoNarrow);
  textSize(15);
  textLeading(15);
  textAlign(LEFT);
  stroke(tutorialColor);
  strokeWeight(1);  
  String msg = "Os CÍRCULOS mostram os\npaíses dos clubes onde os\nconvocados atuam. Ao clicar\nneles, você descobre:";
  text(msg, textPos.x, textPos.y);

  textPos.y += 80;
  msg = "1. Quantos jogadores atuando\nnaquele país pertencem a\ncada uma das seleções";
  text(msg, textPos.x, textPos.y);

  Arc a = allArcs.get(0);
  float angle = (a.endAngle + a.startAngle)/2;
  arrowPos.x = a.pos.x + cos(angle) * a.radius * 0.96;
  arrowPos.y = a.pos.y + sin(angle) * a.radius * 0.96;
  line(textPos.x + 150, arrowPos.y, arrowPos.x, arrowPos.y);
  ellipse(arrowPos.x, arrowPos.y, 3, 3);
  
  textPos.y += 80;
  msg = "2. O NÚMERO e a\nÁREA DO CÍRCULO\nindicam o total de\nconvocados atuando ali";
  text(msg, textPos.x, textPos.y);

  Circle c = allCircles.get(5);
  selectedType = "circle";
  selectedCountry = c.thisCountry;
  dimColors();
  c.isActive = true;
  for (Player p : c.clubPlayers) {
    p.isActive = true;
    p.originCountry.isActive = true;
  }
  
  arrowPos.x = c.pos.x - 15;
  arrowPos.y = c.pos.y + 15;  
  line(textPos.x + 150, arrowPos.y, arrowPos.x, arrowPos.y);
  ellipse(arrowPos.x, arrowPos.y, 3, 3);  
  noFill();

  arrowPos.x = c.pos.x;
  arrowPos.y = c.pos.y + c.radius;  
  ellipse(arrowPos.x, arrowPos.y - c.radius, c.radius*2, c.radius*2);
  
  /*---------- SECOND SCREEN ----------*/

//  Arc a = allArcs.get(0);
//  float angle = (a.endAngle + a.startAngle)/2;
//  arrowPos.x = a.pos.x + cos(angle) * a.radius * 0.95;
//  arrowPos.y = a.pos.y + sin(angle) * a.radius * 0.95;
//  line(textPos.x + 130, textPos.y + 15, arrowPos.x, arrowPos.y);
//  ellipse(arrowPos.x, arrowPos.y, 3, 3);
//
//  pushMatrix();
//  translate(arrowPos.x, arrowPos.y);
//  rotate(angle + PI/2);  
//  textFont(archivoNarrowBold);
//  textSize(12);
//  textAlign(CENTER, TOP);
//  text("6", 0, 0);  
//  popMatrix();
//
//  Circle c = allCircles.get(5);
//  textPos.y = c.pos.y;
//  msg = "Ao clicar nas seleções, mostra a\nQUANTIDADE DE CONVOCADOS\nem atuação nos clubes do país";
//  textFont(archivoNarrow);
//  textSize(15);
//  textLeading(15);
//  textAlign(LEFT);  
//  text(msg, textPos.x, textPos.y);
//
//  arrowPos.x = c.pos.x - 15;
//  arrowPos.y = c.pos.y + 15;  
//  line(textPos.x + 200, textPos.y + 15, arrowPos.x, arrowPos.y);
//  ellipse(arrowPos.x, arrowPos.y, 3, 3);
//  textFont(archivoNarrowBold);
//  textSize(12);
//  textAlign(CENTER, TOP);
//  text("122", c.pos.x, c.pos.y + 10);
//
//  textPos.y = 570;
//  textFont(archivoNarrow);
//  textSize(15);
//  textLeading(15);
//  textAlign(LEFT);
//  msg = "A área do círculo corresponde\nao NÚMERO DE CONVOCADOS\nque jogam nos clubes daquele país";
//  text(msg, textPos.x, textPos.y);
//
//  c = allCircles.get(2);
//  arrowPos.x = c.pos.x;
//  arrowPos.y = c.pos.y + c.radius;
//  line(textPos.x + 190, textPos.y + 15, arrowPos.x, textPos.y + 15);
//  line(arrowPos.x, textPos.y + 15, arrowPos.x, arrowPos.y);
//  noFill();
//  ellipse(arrowPos.x, arrowPos.y - c.radius, c.radius*2, c.radius*2);
}
