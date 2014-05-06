ArrayList placeMarkers = new ArrayList();
PImage worldMap;

void setup() {
  size(1200, 600);
  smooth();
  
  worldMap = loadImage("worldmap-equirectangular-s.jpg");

  queryAndCreatePlaces("coordinates.tsv");
}

void draw() {
  image(worldMap, 0, 0, width, height);
  
  for (int i = 0; i < placeMarkers.size(); i++) {
    PlaceMarker pm = (PlaceMarker) placeMarkers.get(i);
    pm.display();
  }
}

void queryAndCreatePlaces(String filename) {
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    String name = myLine[0];
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    PlaceMarker placeMarker = new PlaceMarker(name, lat, lng);
    placeMarkers.add(placeMarker);
  } 
}
