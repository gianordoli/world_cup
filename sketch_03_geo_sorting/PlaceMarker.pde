class PlaceMarker {

  String name;
  float lat;
  float lng;
  PVector pos;
  float angle;

  PlaceMarker(String name, float lat, float lng) {
    this.name = name;
    this.lat = lat;
    this.lng = lng;
    pos = new PVector();
  }

  void display() {
    
    noStroke();
    fill(255, 0, 0, 50);
    ellipse(pos.x, pos.y, 15, 15);
    fill(255, 0, 0, 200);
    ellipse(pos.x, pos.y, 5, 5);
    
    fill(255);
    text(name, pos.x, pos.y);
    text(angle, pos.x, pos.y + 12);
  }

//  String toString() {
//    return name + " (" + lat + ", " + lng + ")";
//  }
}

