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

int mm = 4;

ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

ArrayList<Circle> allCircles;
ArrayList<Arc> allArcs;

PFont glober;
float margin = 20*mm;

void setup() {
  size(404*mm, 266*mm);
  colorMode(HSB, 360, 100, 100);

  glober = createFont("GloberBold", 8);
  

  /*----- COUNTRIES -----*/
//  allCountries = initCountries("countries_groups.tsv"); 
  allCountries = initCountries("countries_continents.tsv");
  Country prevCountry = allCountries.get(0);
  int group = 0;
  for(int i = 0; i < allCountries.size(); i++){
    Country c = allCountries.get(i);
    
    if(!c.continent.equals(prevCountry.continent)){
      group = 0;
    }else{
      group ++;
    }
    c.setColor(group);
    
    prevCountry = allCountries.get(i);
  }
//  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");
  allCircles = loadCircles("countries_sorted_by_continents.txt");

  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  
  String[] sortedCountries = new String[allCountries.size()];
  for(int i = 0; i < allCountries.size(); i++){
    sortedCountries[i] = allCountries.get(i).name;
  }    
  //Sorting the players based on the original country list
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");
  
  /*------ ARCS ------*/
  sortedCountries = new String[allCircles.size()];
  for(int i = 0; i < allCircles.size(); i++){
    sortedCountries[i] = allCircles.get(i).thisCountry.name;
  }    
  //Sorting the arcs based on the original country list  
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
  for(Arc a : allArcs){
    //Sorting the list based on the upper list
    a.teamPlayers = sortPlayers(a.teamPlayers, sortedCountries, "current");
    //Linking to the circles
    a.linkCircles();
    a.setPlayersPositions();
  }

  allCircles = setCircles(allCircles);
  for(Circle c : allCircles){
    c.setPlayersPositions();
  }  

  debug();
}

void draw() {
  if(record){
      beginRecord(PDF, "world_cup.pdf");
  }
  
  background(360);
    
  for(Arc a : allArcs){ 
    for(Player p : a.teamPlayers){
      p.display();
    }    
    a.display();
  }
  
//  for (Circle c : allCircles) {
  for(int i = 0; i < allCircles.size(); i++){
//    c.display();
    Circle c = allCircles.get(i);
    c.display(i);
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

ArrayList<Circle> loadCircles(String filename) {
  ArrayList<Circle> tempList = new ArrayList<Circle>();
  String[] tableString = loadStrings(filename);
    
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);

    for (Country c : allCountries) {
      if(name.equals(c.name)){
        Circle myCircle = new Circle(c);
        tempList.add(myCircle);
//        println(name);
        break;
      }
    }
  }
  return tempList;
}

ArrayList<Circle> setCircles(ArrayList<Circle> theseCircles){
  
  ArrayList<Circle> tempList = theseCircles;
  float barOffset = 1*mm;
  float start = margin;
  float end = 0;
    
  for(int i = 0; i < tempList.size(); i++){
    
    Circle c = tempList.get(i);
    float barLength = map(c.teamPlayers.size(), 0, allPlayers.size(), 0, width - (theseCircles.size() - 1) * barOffset - 2*margin);
    
    end = start + barLength;
    
      c.setCircleParam(start, barLength);
    
    start = end + barOffset;  //Next
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
  float barOffset = 1*mm;
  float start = margin;
  float end = margin;
  
  for(int i = 0; i < tempList.size(); i++){
    
    Arc a = tempList.get(i);
//    float barLength = (width - (tempList.size() - 1) * barOffset - 2*margin) / tempList.size();
  float barLength = map(a.teamPlayers.size(), 0, allPlayers.size(), 0, width - (theseArcs.size() - 1) * barOffset - 2*margin);
    
    end = start + barLength;
    
      a.setArcParam(start, barLength);
    
    start = end + barOffset;  //Next
  }
  
  return tempList;
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

