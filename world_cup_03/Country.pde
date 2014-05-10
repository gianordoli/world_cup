class Country {

  String name;
  String group;
  PVector pos;
  PVector controlPoint;
  float radius;
  float final_radius;
  int totalPlayers;  
  color myColor;

  Country(String _name, float lat, float lng) {
    name = _name;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);
    setControlPoint();    
  }
  
  void setControlPoint(){
      float offset = 20*mm;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + final_radius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + final_radius + offset);  
  }
  
//  void setColor(float h, float s, float b){
//    myColor = color(h, s, b);
//  }
  
  void setColor(String filename){
  String[] tableString = loadStrings(filename);
    for (String lineString : tableString) {
      String[] myLine = split(lineString, "\t");
      if(trim(myLine[0]).equals(this.name)){
        group = trim(myLine[1]);
      }
    }
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float h, s, b;
    //group int: "a" to "h"
    h = map(groupInt, 97, 104, 0, 255);
    if(groupInt < 97){
      s = 0;
      b = 170;
    }else{
      s = 225;
      b = 255;    
    }
    myColor = color(h, s, b);
  }  
  
  void setRadius(int max){
    final_radius = map(totalPlayers, 0, max, 2*mm, 10*mm);
  }
  
  void update(){
    float padding = 3*mm; //space in between the circles
    for(Country c : allCountries){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.1;
        pos.y += escape.y * 1.1;
        
        setControlPoint();        
      }    
    }  
  }  

  void display() {
    
    if(radius < final_radius * 0.99){
      radius += (final_radius - radius) * 0.1;
    }
    
    noStroke();
    fill(myColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    PVector boxSize = new PVector(20*mm, 4*mm);
//    fill(myColor);
//    rectMode(CENTER);
//    rect(pos.x, pos.y, boxSize.x, boxSize.y);
    
    fill(0);
    textSize(8);
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textLeading(8);
    text(name, pos.x - boxSize.x/2, pos.y - boxSize.x/2, boxSize.x, boxSize.x);
  }
}

