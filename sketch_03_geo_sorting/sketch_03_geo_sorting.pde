/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com
 
 Geoplacing countries and then sorting list
 based on geolocation (based on angle 0-2*PI).
 The geoplacement here is based on Till Nagel's tutorial
 "Processing geo information in Wikipedia articles" 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html
--------------------------------------------------------------------------- */

ArrayList placeMarkers = new ArrayList();
PImage worldMap;
PVector center;

void setup() {
  size(1200, 600);
  smooth();
  
  worldMap = loadImage("worldmap-equirectangular-s.jpg");
  center = new PVector(width/2, height/2 - 100);
  
  queryAndCreatePlaces("coordinates_pt.tsv");
  setPositions(placeMarkers);
  setAngles(placeMarkers);
  sortBy(placeMarkers, "angle");
  saveSorted(placeMarkers);
}

void draw() {
  image(worldMap, 0, 0, width, height);
  
  for (int i = 0; i < placeMarkers.size(); i++) {
    PlaceMarker pm = (PlaceMarker) placeMarkers.get(i);
    pm.display();
  }
  
  float mouseAngle = atan2(mouseY - center.y, mouseX - center.x);
  if(mouseAngle < 0) {
    mouseAngle = TWO_PI - abs(mouseAngle); 
  }
  fill(255);
  text(mouseAngle, mouseX, mouseY);
}

void queryAndCreatePlaces(String filename) {
  String[] tableString = loadStrings(filename);
  for(int i =0; i < tableString.length; i++){
    tableString[i] = trim(tableString[i]);
  }  
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    String name = myLine[0];
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    PlaceMarker placeMarker = new PlaceMarker(name, lat, lng);
    placeMarkers.add(placeMarker);
  } 
}

void setPositions(ArrayList myList){
  for(int i = 0; i < myList.size(); i++){
    PlaceMarker pm = (PlaceMarker) myList.get(i);
    // Equirectangular projection
    pm.pos.x = map(pm.lng, -180, 180, 0, width); 
    pm.pos.y = map(pm.lat, 90, -90, 0, height);    
  }
}

void setAngles(ArrayList myList){
  
  for(int i = 0; i < myList.size(); i++){
    PlaceMarker pm = (PlaceMarker) myList.get(i);
    float angle = atan2(pm.pos.y - center.y, pm.pos.x - center.x);
    if(angle < 0) {
      angle = TWO_PI - abs(angle); 
    }
    pm.angle = angle;
  }
}

void sortBy(ArrayList myList, String comparator){
  //Creating an empty array that will store the values
  //we want to compare
  float[] values = new float[myList.size()];
  for(int i = 0; i < myList.size(); i++){
    PlaceMarker pm = (PlaceMarker) myList.get(i);
    //We'l compare based on...?
    if(comparator == "angle"){
      values[i] = pm.angle;
    }
  }
  //Sorting those values
  values = sort(values);
//  values = reverse(values);
  
  //This temporary ArrayList will store the objects sorted
  ArrayList tempList = new ArrayList();
  
  //Looping through each sorted value
  for(int i = 0; i < values.length; i++){
    //Looping through each object
    for(int j = 0; j < myList.size(); j++){
      PlaceMarker pm = (PlaceMarker) myList.get(j);
      //We'l compare based on...?
      float objectValue = 0;
      if(comparator == "angle"){
        objectValue = pm.angle;  
      }
      
      //If the sorted value is found...
      if(values[i] == objectValue){
        //Add the object to the temporary list and jump to the next iteration
        tempList.add(pm);
        myList.remove(pm);
        break;
      }
    }
  }
  for(int i = 0; i < tempList.size(); i++){
    PlaceMarker pm = (PlaceMarker) tempList.get(i);
    myList.add(pm);
  }
}

void saveSorted(ArrayList myList){
  String[] sortedValues = new String[myList.size()];
  for(int i = 0; i < myList.size(); i++){
    PlaceMarker pm = (PlaceMarker) myList.get(i);
//    println(pm.name + "\t" + pm.pos.x + "\t" + pm.pos.y + "\t" + pm.angle);
    sortedValues[i] = pm.name;
  }
  saveStrings("countries_sorted_by_angle_pt.txt", sortedValues);
}
