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
}
