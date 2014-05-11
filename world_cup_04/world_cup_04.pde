import processing.pdf.*;
boolean record = false;

int mm = 3;

ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

ArrayList<Circle> allCircles;
ArrayList<Arc> allArcs;

PShape worldMap;
PVector worldMapPos;
PVector worldMapSize;
PVector center;

PImage layout;

void setup() {
  //  JS:
//size(800, 1000);
  size(266*mm, 300*mm);
  colorMode(HSB);
//  frameRate(30);

  center = new PVector(width/2, height/2);
  
  layout = loadImage("GA275_numeralhaCopa.png");  

  //Loading and positioning map
  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapSize = new PVector(worldMap.width + 80*mm, worldMap.height + 80*mm);
  worldMapPos = new PVector((width - worldMapSize.x)/2 - 5*mm, (height - worldMapSize.y)/2 + 30*mm);

  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv");  
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");

  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  //Players' positions in the arc will be based on this sorted list
  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt"); 
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");  //Sorting the arcs
  
  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
//  for(Arc a : allArcs){              //Sorting the list
//    a.teamPlayers = sortPlayers(a.teamPlayers, sortedCountries, "current");
//  }  

//  linkPlayersAndCoutries();  //Linking the 2 ArrayLists  
//  setPlayersPositions();     //Setting arc points
//
//  //Now that we have all players, we can set the radius of each country
//  setCountriesRadii();

  debug();
}

void draw() {
  if(record){
      beginRecord(PDF, "world_cup.pdf");
  }
  
  background(255);
//  image(layout, 0, 0, width, height);
//  fill(0, 10);
//  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);

  for(Arc a : allArcs){
//  for(int i = 0; i < limit; i++){
//  Arc a = allArcs.get(i);
  
    a.display();
//    for(Player p : t.teamPlayers){
//      p.display();
//    }
  }

  for (Circle c : allCircles) {
    c.update();
    c.display();
  }

  if(record){
    endRecord();
    record = false;
  }  
}

void mousePressed(){
  record = true;
}

ArrayList<Country> initCountries(String filename){
  ArrayList<Country> tempList = new ArrayList<Country>();
  String[] tableString = loadStrings(filename);
    for (String lineString : tableString) {
      String[] myLine = split(lineString, "\t");
      String name = trim(myLine[0]);
      String group = trim(myLine[1]);
      Country thisCountry = new Country(name, group);
      thisCountry.setColor();
      tempList.add(thisCountry);
    }
    return tempList;
}

ArrayList<Circle> loadCirclesCoordinates(String filename) {
  ArrayList<Circle> tempList = new ArrayList<Circle>();
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);

    for (Country c : allCountries) {
      if(name.equals(c.name)){
        Circle myCircle = new Circle(c, lat, lng);
        tempList.add(myCircle);
//        println(name);
        break;
      }
    }
  }
  return tempList;
}

ArrayList<Player> loadPlayers(String filename) {
  ArrayList<Player> tempList = new ArrayList<Player>();  
  
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[1]);
    String originString = trim(myLine[0]);
    String club = trim(myLine[2]);
    String currentString = trim(myLine[3]);
    
    Country origin = new Country("", "");
    for (Country c : allCountries) {
      if(originString.equals(c.name)){
        origin = c;
        break;
      }
    }
    Country current = new Country("", "");
    for (Country c : allCountries) {
      if(currentString.equals(c.name)){
        current = c;
        break;
      }
    }
    Player p = new Player(name, origin, club, current);
    tempList.add(p);    
  }
  return tempList;
}

ArrayList<Player> sortPlayers(ArrayList<Player> thesePlayers, String[] sortedCountries, String criteria) {
  ArrayList<Player> tempList = new ArrayList<Player>();
  for(String s : sortedCountries){
    s = trim(s);
  }  
  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {
    //Looping through each object
    for (int j = 0; j < thesePlayers.size(); j++) {
      String thisValue = "";
      if(criteria.equals("origin")){
        thisValue = thesePlayers.get(j).origin.name;
      }else if(criteria.equals("current")){
        thisValue = thesePlayers.get(j).current.name;
      }
      //If the sorted value is found...
      if (sortedCountries[i].equals(thisValue)) {
        //Add the object to the temporary list
        tempList.add(thesePlayers.get(j));
      }
    }
  }
  return tempList;
}

ArrayList<Arc> createArcs(ArrayList<Player> thesePlayers){
  
  ArrayList<Arc> tempList = new ArrayList<Arc>();
  
  Country prevCountry = new Country("", "");
  ArrayList<Player> tempPlayers = new ArrayList<Player>();
  
  for(int i = 0; i < thesePlayers.size(); i++){
    
    Player p = thesePlayers.get(i);
    
    //If the current player's country is different from the previous...
    if(!p.origin.name.equals(prevCountry.name)){
      //If it is not the first player...
      if(i != 0){
        //Create a new team based on the previous information
        tempList.add(new Arc(prevCountry, tempPlayers));      
      } 
      //Cleaned the list up
      tempPlayers = new ArrayList();
    }
    
    tempPlayers.add(p);
    
    //Wait! Was it the last player?
    if(i == thesePlayers.size() - 1){
      tempList.add(new Arc(prevCountry, tempPlayers));   
    }    
    
    prevCountry = p.origin;    
  }
  return tempList;
}

ArrayList<Arc> setArcs(ArrayList<Arc> theseArcs){
  
  ArrayList<Arc> tempList = theseArcs;
  float angleOffset = 0.005 * PI; //Distance between each arc
    
  //Filling the lower part in
  float radius = 137*mm;
  float x = center.x;
  float y = center.y + 5*mm;
  float startAngle = 0.15 * PI;
  float endAngle = 0;
  
  for(int i = 0; i < tempList.size(); i++){
    Arc a = tempList.get(i);
    float arcLength = (1.4*PI - (tempList.size() - 1) * angleOffset) / tempList.size();
    
    endAngle = startAngle + arcLength;
    
    a.setArcParam(x, y, radius, startAngle, endAngle);
    
    startAngle = endAngle + angleOffset;  //next
    
    //Next arc
    if(i == tempList.size()/2 - 1){
      startAngle += 0.3 * PI;
    }
  }
  
  return tempList;
}

//void setCountriesRadii() {
//  for (Circle c : allCircles) {
//    for (Player p : allPlayers) {
//      if (p.clubCountry.equals(c.name)) {
//        c.totalPlayers ++;
//      }
//    }
//  }
//
//  int maxPlayers = getMax(allCircles);
//  for (Circle c : allCircles) {
//    //    println(c.name + "\t" + c.totalPlayers);
//    c.setRadius(maxPlayers);
//  }
//}


//void setPlayersPositions() { 
//  float radius = 137*mm;
//  float centerOffset = 5*mm;
//  
//  ArrayList<Player> tempPlayers = new ArrayList();
//  String prevCircle = "";
//  float prevRX = 0;
//  float prevRY = 0;
//  float startAngle = 0;
//  float endAngle = 0;
//
//  for (int i = 0; i < allPlayers.size(); i++) {
//
//    Player thisPlayer = allPlayers.get(i);
//
//    //Position    
//    float angle = map(i, 0, allPlayers.size() - 1, 0.15 * PI, 1.55 * PI);
//    if(angle > 0.85 * PI){
//      angle += 0.3 * PI;
//      centerOffset = -5*mm;
//    }    
//      
//    float rX = center.x;
//    float rY = center.y + centerOffset;
//    float offset = 30*mm;  //distance from arc to control point
//    float x1 = rX + cos(angle) * radius;
//    float y1 = rY + sin(angle) * radius;
//    float x2 = rX + cos(angle) * (radius - offset);
//    float y2 = rY + sin(angle) * (radius - offset);    
//
//    thisPlayer.setPos(x1, y1, x2, y2);
//    thisPlayer.setAngle(angle);
//    
//    //Is this player's team different from the previous one?
//    if(!thisPlayer.country.equals(prevCircle)){
//      //If it is not the first player...
//      if(i != 0){
//        //Create a new team based on the previous information
//        allArcs.add(new Arc(prevCircle, tempPlayers, prevRX, prevRY, radius, startAngle, endAngle));      
//      } 
//      
//      //Start a new team/Clean the previous list up 
//      startAngle = angle;
//      tempPlayers = new ArrayList();
//    }
//    
//    tempPlayers.add(thisPlayer);
//    endAngle = angle;
//    prevRX = rX;
//    prevRY = rY;
//    
//    //Wait! Was it the last player?
//    if(i == allPlayers.size() - 1){
//      allArcs.add(new Arc(prevCircle, tempPlayers, prevRX, prevRY, radius, startAngle, endAngle));   
//    }    
//    
//    prevCircle = thisPlayer.country;
//  }
//}
//
//void linkPlayersAndCoutries() {
//
//  //Club country
//  for (Circle c : allCircles) {
//    for (Player p : allPlayers) {
//      if (p.clubCountry.equals(c.name)) {
//        p.currCountry = c;
//      }
//    }
//  }
//}

int getMax(ArrayList<Circle> myList) {
  int max = 0;
  for (Circle c : myList) {
    if (c.totalPlayers > max) {
      max = c.totalPlayers;
    }
  }
  return max;
}

void debug() {
//  for(Country c : allCountries){
//    println(c.name + "\t" + c.group + "\t" + c.myColor);
//  }
//  for(Circle c: allCircles){
//    println(c.thisCountry.name);
//  }  
//  for (Player p : allPlayers) {
//    println(p.name + " \t" + p.origin.name);
//  }
//  for(Arc a: allArcs){
//    print(a.thisCountry.name + ":" + a.teamPlayers.size());
//    for(Player p : a.teamPlayers){
//      println("\t" + p.name);
//    }
//  }
}

//boolean sketchFullScreen() {
//  return true;
//}

