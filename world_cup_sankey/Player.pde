//Draws lines
class Player {
  String name, club;
  Country origin, current;
  ArrayList<PVector> anchors;
  float angle;
  
  Circle currCountry;

  Player(String _name, Country _origin, String _club, Country _current) {
    name = _name;
    origin = _origin;
    club = _club;
    current = _current;
    anchors = new ArrayList<PVector>();
  }

  void setPos(float x1, float y1, float x2, float y2) {
    anchors.add(new PVector(x1, y1));
    anchors.add(new PVector(x2, y2));    
  }

  void display() {
    
    //Line
    noFill();
    strokeWeight(0.3*mm);
    stroke(currCountry.thisCountry.myColor, 100);

//    bezier(anchors.get(0).x, anchors.get(0).y, 
//           anchors.get(1).x, anchors.get(1).y,
//           currCountry.controlPoint.x, currCountry.controlPoint.y,
//           currCountry.pos.x, currCountry.pos.y);
           
    bezier(anchors.get(0).x, anchors.get(0).y, 
           anchors.get(1).x, anchors.get(1).y,
           anchors.get(2).x, anchors.get(2).y,
           anchors.get(3).x, anchors.get(3).y);           
  }
}

