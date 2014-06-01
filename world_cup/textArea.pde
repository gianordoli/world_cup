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
    leading = 15;
    
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
    scrollbarY = areaY;
    isDragging = false;  
  }  

  boolean isHovering(){
    if(scrollbarY < mouseY && mouseY < scrollbarY + 15
    && areaX + areaWidth < mouseX && mouseX < areaX + areaWidth + 15
    && hasScroll){
      return true;
    }else{
      return false;
    }
//    println(isDragging);    
  }
  
  void drag(){
    if(isDragging){
      scrollbarY = constrain(mouseY, areaY, areaY + areaHeight - 15);
      textY = map(scrollbarY, areaY, areaY + areaHeight - 15, 0, areaHeight - textHeight);
//      textY = constrain(textY, areaHeight - textHeight, 0);    
    }  
  }
  
  void scrollbar(){
    fill(240);
    noStroke();
    rect(areaX + areaWidth + 6, areaY, 3, areaHeight);
    
    fill(100);
    rect(areaX + areaWidth, scrollbarY, 15, 15);
  }

  void display() {

    if(hasScroll){
      scrollbar();
    }
    
    textRect.beginDraw();
    textRect.background(255);
    textRect.fill(100);
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
