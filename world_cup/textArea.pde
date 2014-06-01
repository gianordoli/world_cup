class TextArea {
  
  PGraphics textRect;  //Mask. The text is drawn inside of it
  String[] col1;
  String[] col2;
  String[] col3;
  
  //These vars don't vary
  int areaX;           //Mask X
  int areaY;           //Mask y
  int areaWidth;       //Mask width
  int areaHeight;      //Mask height
  int leading;
  
  //These vars vary!
  float textY;         //Actual text area y
  float textHeight;    //Actual text area height. Needs to be calculated counting the rows
  float scrollbarY;    //Scrollbar changing coordinate;

  boolean isDragging;  //Checks if the scrollbar is being dragged
  boolean hasScroll;   //Checks if the text height is greater then the area, i.e., if it needs a scrollbar

//  TextArea(String[] tempText, int tempAreaX, int tempAreaY, int tempAreaWidth, int tempAreaHeight) {
  TextArea(int _areaX, int _areaY, int _areaWidth, int _areaHeight) {
    
    areaX = _areaX;
    areaY = _areaY;
    areaWidth = _areaWidth;
    areaHeight = _areaHeight;
    leading = 14;
    
    textRect = createGraphics(areaWidth, areaHeight);
  }
  
  //Calculates text height
  void setText(String[] _col1, String[] _col2, String[] _col3){
    
    col1 = _col1;
    col2 = _col2; 
    col3 = _col3;
 
    textHeight = col1.length * leading;
    if(textHeight > areaHeight){
      hasScroll = true;
    }else{
      hasScroll = false;
    }
 
    //Reset scroll!
    textY = 0;
    scrollbarY = areaY + 7;
    isDragging = false;  
  }  

  boolean isHovering(){
    if(scrollbarY - 7 < mouseY && mouseY < scrollbarY + 7
    && areaX + areaWidth < mouseX && mouseX < areaX + areaWidth + 14
    && hasScroll){
      return true;
    }else{
      return false;
    }
//    println(isDragging);    
  }
  
  void drag(){
    if(isDragging){
      scrollbarY = constrain(mouseY, areaY + 7, areaY + areaHeight - 7);
      textY = map(scrollbarY, areaY + 7, areaY + areaHeight - 7, 0, areaHeight - textHeight);
    }  
  }
  
  void scrollbar(){
    strokeWeight(2);
    stroke(labelColor, 100);
    noFill();
    line(areaX + areaWidth + 7, areaY, areaX + areaWidth + 6, areaY + areaHeight);
    
    noStroke();
    fill(labelColor);
    rectMode(CENTER);
    rect(areaX + areaWidth + 7, scrollbarY, 14, 14, 3);
  }

  void display() {

    if(hasScroll){
      scrollbar();
    }
    
    textRect.beginDraw();
    textRect.background(bgColor);
    textRect.fill(255);
    textRect.textFont(archivoNarrow);
    textRect.textSize(12);
    
    if(selectedType.equals("arc")){
      textRect.textAlign(LEFT, TOP);  
      for(int i = 0; i < col1.length; i++){
        textRect.text(col1[i], 0, textY + i*leading);
        textRect.text(col2[i], 110, textY + i*leading);
      }
    }else if(selectedType.equals("circle")){
      for(int i = 0; i < col1.length; i++){
        textRect.textAlign(LEFT, TOP);
        textRect.text(col1[i], 0, textY + i*leading);
        textRect.textAlign(CENTER, TOP);
        textRect.text(col2[i], 110, textY + i*leading);
        textRect.textAlign(LEFT, TOP);
        textRect.text(col3[i], 130, textY + i*leading);
      }
    }
    textRect.endDraw();    
    
    image(textRect, areaX, areaY);
  }
}
