/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com

 Geoplacement based on Till Nagel's tutorial: 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html 
--------------------------------------------------------------------------- */

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

//animation
int interval;
int transition1;
int transition2;
int transition3;

PFont glober;

void setup() {
  //  JS:
//size(800, 900);
  size(266*mm, 300*mm);
  colorMode(HSB);
//  frameRate(30);

  glober = createFont("GloberBold", 8);
  
  center = new PVector(width/2, height/2);

  //Loading and positioning map
  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapSize = new PVector(worldMap.width * 2.5, worldMap.height * 3);
  worldMapPos = new PVector((width - worldMapSize.x)/2 - 15*mm, (height - worldMapSize.y)/2 + 30*mm);

  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv"); 
  for(int i = 0; i < allCountries.size(); i++){
    Country c = allCountries.get(i);
    c.setColor(i);
  }
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");

  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  //Players' positions in the arc will be based on this sorted list
//  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  String[] sortedCountries = loadStrings("countries_sorted_by_groups.txt");
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");  //Sorting the arcs
  
  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
  for(Arc a : allArcs){
    //Sorting the list
    a.teamPlayers = sortPlayers(a.teamPlayers, sortedCountries, "current");
    //Linking to the circles
    a.linkCircles();
    a.setPlayersPositions();
  }

  //Now that we've linked players and circles,
  //let's calculate the circle radius based on the number
  //of players linked to it
  int maxPlayers = getMax(allCircles);
  for (Circle c : allCircles) {
    c.setRadius(maxPlayers);
  }  

  debug();
  
  interval = 1000;
  transition1 = millis() + 3000;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
}

void draw() {
  if(record){
      beginRecord(PDF, "world_cup.pdf");
  }
  
  background(255);
//  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);

  if(millis() > transition1){
    
    for(Arc a : allArcs){
      
      if(millis() > transition2){
        for(Player p : a.teamPlayers){
          p.display();
        }
      }      
      a.display();
    }
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
//      thisCountry.setColor();
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

