//Draws lines
class Player {
  String name, country, club, clubCountry;
  ArrayList<PVector> anchors;
  float angle;
  
  Country currCountry;

  Player(String _name, String _country, String _club, String _clubCountry) {
    name = _name;
    country = _country;
    club = _club;
    clubCountry = _clubCountry;
    anchors = new ArrayList<PVector>();
  }

  void setPos(float x1, float y1, float x2, float y2) {
    anchors.add(new PVector(x1, y1));
    anchors.add(new PVector(x2, y2));    
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display() {
    //Line
    noFill();
    strokeWeight(0.3*mm);
    stroke(currCountry.myColor, 100);
//    line(anchors.x, anchors.y, currCountry.pos.x, currCountry.pos.y);
    bezier(anchors.get(0).x, anchors.get(0).y, 
           anchors.get(1).x, anchors.get(1).y,
           currCountry.controlPoint.x, currCountry.controlPoint.y,
           currCountry.pos.x, currCountry.pos.y);
  }
}

