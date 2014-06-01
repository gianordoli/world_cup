class TextArea {
  
  PGraphics textRect;  //Mask. The text is drawn inside of it
  String[] col1;
  String[] col2;
  
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
  Boolean isDragging;  //Checks if the scrollbar is being dragged
  Boolean hasScroll;   //Checks if the text height is greater then the area, i.e., if it needs a scrollbar

//  TextArea(String[] tempText, int tempAreaX, int tempAreaY, int tempAreaWidth, int tempAreaHeight) {
  TextArea(int _areaX, int _areaY, int _areaWidth, int _areaHeight) {
    
    areaX = _areaX;
    areaY = _areaY;
    areaWidth = _areaWidth;
    areaHeight = _areaHeight;
    leading = 20;
    
    textY = 0;
    scrollbarY = areaY;
    isDragging = false;
    
    textRect = createGraphics(areaWidth, areaHeight);
  }
  
  //Calculates text height
  void setText(String[] _col1, String[] _col2){
    
    col1 = _col1;
    col2 = _col2; 
 
    textHeight = col1.length * leading;
    if(textHeight > areaHeight){
      hasScroll = true;
    }else{
      hasScroll = false;
    }   
  }  

  void check(){
    if(scrollbarY < mouseY && mouseY < scrollbarY + 20
    && areaX + areaWidth < mouseX && mouseX < areaX + areaWidth + 20
    && hasScroll){
      isDragging = true;
//      println(isDragging);
    }else{
      isDragging = false;
    }
  }
  
  void drag(){
    if(isDragging){
      scrollbarY = constrain(mouseY, areaY, areaY + areaHeight - 20);
      textY = map(scrollbarY, areaY, areaY + areaHeight - 20, 0, areaHeight - textHeight);
//      textY = constrain(textY, areaHeight - textHeight, 0);    
    }  
  }
  
  void scrollbar(){
    fill(240);
    noStroke();
    rect(areaX + areaWidth, areaY, 20, areaHeight);
    
    fill(100);
    rect(areaX + areaWidth, scrollbarY, 20, 20);
  }

  void display() {

    if(hasScroll){
      scrollbar();
    }
    
    textRect.beginDraw();
    textRect.background(255);
    textRect.fill(100);
//    textRect.textFont(body);
    textRect.textAlign(LEFT, TOP);  
    textRect.textLeading(20); 
    for(int i = 0; i < col1.length; i++){
      textRect.text(col1[i], 0, textY + i*leading);
    }   
    textRect.endDraw();    
    
    image(textRect, areaX, areaY);
  }
}

