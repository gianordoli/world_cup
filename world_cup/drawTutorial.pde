void drawTutorial() {
  
  //Alpha layer
  float alpha = 0;
  if(millis() < transition){
    alpha = map(transition - millis(), interval, 0, 0, 100);
    alpha = constrain(alpha, 0, 100);
    fill(bgColor, alpha);
    rect(0, 0, width, height);    
  }else{
    alpha = 80;
    fill(bgColor, alpha);
    rect(0, 0, width, height);

  //Presets
    color tutorialColor = color(40, 255, 255);
    PVector textPos = new PVector(60, 50);
    PVector arrowPos = new PVector(0, 0);
    String msg = "";
    
    /*---------- FIRST SCREEN ----------*/
    if(showTutorial == 1){
      fill(tutorialColor);
      textFont(archivoNarrow);
      textSize(15);
      textLeading(15);
      textAlign(LEFT);
      stroke(tutorialColor);
      strokeWeight(1);  
      msg = "Os CÍRCULOS mostram os\npaíses dos clubes onde os\nconvocados atuam. Ao clicar\nneles, você descobre:";
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
      
      arrowPos.x = c.pos.x - 15;
      arrowPos.y = c.pos.y + 15;  
      line(textPos.x + 150, arrowPos.y, arrowPos.x, arrowPos.y);
      ellipse(arrowPos.x, arrowPos.y, 3, 3);  
      noFill();
    
      arrowPos.x = c.pos.x;
      arrowPos.y = c.pos.y + c.radius;  
      ellipse(arrowPos.x, arrowPos.y - c.radius, c.radius*2, c.radius*2);
    }
    
    
    /*---------- SECOND SCREEN ----------*/
    else{
      textPos = new PVector(60, 500);    
      fill(tutorialColor);
      textFont(archivoNarrow);
      textSize(15);
      textLeading(15);
      textAlign(LEFT);
      stroke(tutorialColor);
      strokeWeight(1);    
      msg = "As siglas mostram\nas seleções nacionais.\nClicar nelas evidencia\nos países onde os\nconvocados atuam";
      text(msg, textPos.x, textPos.y);
  
      Arc a = allArcs.get(16);
      float angle = (a.endAngle + a.startAngle)/2;
      arrowPos.x = a.pos.x + cos(angle) * a.radius * 1.05;
      arrowPos.y = a.pos.y + sin(angle) * a.radius * 1.05;
      line(textPos.x + 130, arrowPos.y, arrowPos.x, arrowPos.y);
      ellipse(arrowPos.x, arrowPos.y, 3, 3);
  
      textPos.y += 120;
      msg = "Este NÚMERO agora indica\na quantidade de convocados\ndaquela seleção atuando em\ncada um dos países";
      text(msg, textPos.x, textPos.y);
      
      Circle c = allCircles.get(3);
      arrowPos.x = c.pos.x;
      arrowPos.y = c.pos.y + 25;  
      line(textPos.x + 180, textPos.y, arrowPos.x, textPos.y);    
      line(arrowPos.x, textPos.y, arrowPos.x, arrowPos.y);    
      ellipse(arrowPos.x, arrowPos.y, 3, 3);
    }    
  }  
}
