class Connection {
  ArrayList<PVector> anchors;
  float strokeLength;
  color myColor;

  Connection(color _myColor, float _strokeLength, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    myColor = _myColor;
    strokeLength = _strokeLength;
    anchors = new ArrayList<PVector>();
    anchors.add(new PVector(x1, y1));
    anchors.add(new PVector(x2, y2));        
    anchors.add(new PVector(x3, y3));
    anchors.add(new PVector(x4, y4));
  }

  void display() {
    noFill();
    stroke(myColor, 100);
    strokeWeight(strokeLength);
    strokeCap(SQUARE);
    bezier(anchors.get(0).x, anchors.get(0).y, 
            anchors.get(1).x, anchors.get(1).y, 
            anchors.get(2).x, anchors.get(2).y, 
            anchors.get(3).x, anchors.get(3).y); 
  }
}

