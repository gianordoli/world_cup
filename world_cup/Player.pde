//Draws lines
class Player {
  String name, club;
  Country origin, current;
  ArrayList<PVector> anchors;
  float angle;
  
  Circle currCountry;
  Arc originCountry;

  Player(String _name, Country _origin, String _club, Country _current) {
    name = _name;
    origin = _origin;
    club = _club;
    current = _current;
    anchors = new ArrayList<PVector>();
  }

  void setPos(PVector p1, PVector p2, PVector p3, PVector p4) {
    anchors.add(p1);
    anchors.add(p2);    
    anchors.add(p3); 
    anchors.add(p4);    
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display() {
    
    float alpha = 0;
    if(millis() < transition3){
      alpha = map(transition3 - millis(), interval, 0, 0, 100);
      alpha = constrain(alpha, 0, 100);
    }else{
      alpha = 100;
    }  
    
    //Line
    noFill();
    strokeWeight(0.3*mm);
    stroke(currCountry.thisCountry.myColor, alpha);
//    line(anchors.get(0).x, anchors.get(0).y, currCountry.pos.x, currCountry.pos.y);
    bezier(anchors.get(0).x, anchors.get(0).y, 
           anchors.get(1).x, anchors.get(1).y,
           anchors.get(2).x, anchors.get(2).y,
           anchors.get(3).x, anchors.get(3).y);
//    bezier(anchors.get(0).x, anchors.get(0).y, 
//           anchors.get(1).x, anchors.get(1).y,
//           currCountry.controlPoint.x, currCountry.controlPoint.y,
//           currCountry.pos.x, currCountry.pos.y);
  }
}

