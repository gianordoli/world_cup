void drawPlayersList(Country c, int nPlayers){
  
  myTextArea.display();
  
  rectMode(CORNER);
  
  noStroke();
  fill(labelColor);
  rect(105, 186, 60, 14, 5, 5, 0, 0);
  fill(bgColor);
  textFont(archivoNarrowBold);
  textSize(10.5);
  textAlign(CENTER, CENTER);
  if(selectedType.equals("arc")){
    text("SELEÇÃO", 135, 193);
  }else if(selectedType.equals("circle")){
    text("PAÍS", 135, 193);
  }
  
  stroke(labelColor);
  strokeWeight(1);
  line(20, 200, 253, 200);
  line(20, 230, 253, 230);
  if(!myTextArea.hasScroll){
    line(20, myTextArea.areaY + myTextArea.textHeight + 15, 253, myTextArea.areaY + myTextArea.textHeight + 15);
  }else{
    line(20, myTextArea.areaY + myTextArea.areaHeight + 15, 253, myTextArea.areaY + myTextArea.areaHeight + 15);
  }
  
  noStroke();
  fill(c.myColor);
  rect(20, 204, 233, 22);
  
  fill(255);
  textAlign(LEFT, CENTER);
  textFont(archivoNarrowBold);
  textSize(13);
  if(selectedType.equals("arc")){
    text(c.name.toUpperCase() + " - GRUPO " + c.group.toUpperCase(), 24, 215);
  }else if(selectedType.equals("circle")){
    text(c.name.toUpperCase() + ": " + nPlayers + " jogadores", 24, 215);
  }
}
