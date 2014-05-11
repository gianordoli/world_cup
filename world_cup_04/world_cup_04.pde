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
//  worldMapPos = new PVector(70*mm, 90*mm);
  worldMapSize = new PVector(worldMap.width + 80*mm, worldMap.height + 80*mm);
  worldMapPos = new PVector((width - worldMapSize.x)/2 - 5*mm, (height - worldMapSize.y)/2 + 30*mm);
//  worldMap.disableStyle();

  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv");  
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");
  
//  setCountriesColors("countries_groups.tsv");

  /*------ PLAYERS ------*/
  allArcs = new ArrayList<Arc>();
  allPlayers = loadPlayers("players_pt.tsv");
  
  //Players' positions in the arc will be based on this sorted list
  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt"); 
  allPlayers = sortPlayersByOrigin(allPlayers, sortedCountries);  //Sorting the arcs
  
  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);
//    sortPlayersByCurrent(sortedCountries); //Sub-sorting the lines
//    
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

//  for(Arc t : allArcs){
//    t.display();
//    for(Player p : t.teamPlayers){
//      p.display();
//    }
//  }

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
        println(name);
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

ArrayList<Player> sortPlayersByOrigin(ArrayList<Player> thesePlayers, String[] sortedCountries) {
  ArrayList<Player> tempList = new ArrayList<Player>();
  for(String s : sortedCountries){
    s = trim(s);
  }  
  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {
    //Looping through each object
    for (int j = 0; j < thesePlayers.size(); j++) {
      String thisValue = thesePlayers.get(j).origin.name;
      //        println("\t" + thisValue);
      //If the sorted value is found...
      if (sortedCountries[i].equals(thisValue)) {
        //Add the object to the temporary list
        tempList.add(thesePlayers.get(j));
      }
    }
  }
  return tempList;
}

//ArrayList<Arc> createArcs(ArrayList<Player> thesePlayers){
//  ArrayList<Arc> tempList = new ArrayList<Arc>();
//  for()
//
//}

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



//void sortPlayersByCurrent(String[] sortedCountries) {
//  //New list
//  ArrayList<Player> tempList = new ArrayList<Player>();
//
//  int a = 0;
//
//  while (a < allPlayers.size () - 1) {
//    //Current country
//    ArrayList<Player> tempListCircle = new ArrayList<Player>();
//    int i = a;
//    String currCountry = allPlayers.get(a).country;
//    while (currCountry.equals (allPlayers.get (i).country) && i < allPlayers.size() - 1) {
//      tempListCircle.add(allPlayers.get(i));
//      i++;
//    }
//    if (i == allPlayers.size() - 1) {
//      tempListCircle.add(allPlayers.get(i));
//    }
//    //    i--;
//    //  for(Player p : tempListCircle){
//    //    println(p.country + "\t" + p.clubCountry);
//    //  }  
//
//    for (int j = 0; j < sortedCountries.length; j++) {
//      for (int k = 0; k < tempListCircle.size(); k++) {
//        Player p = tempListCircle.get(k);      
//        if (sortedCountries[j].equals(p.clubCountry)) {
//          tempList.add(p);
//          //          allPlayers.remove(p);
//        }
//      }
//    }   
//    a = i;
//    //    println(a);
//  }
//
//  allPlayers = tempList;
//}
//
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
  for(Country c : allCountries){
    println(c.name + "\t" + c.group + "\t" + c.myColor);
  }
  for(Circle c: allCircles){
    println(c.thisCountry.name);
  }  
  for (Player p : allPlayers) {
    println(p.name + " \t" + p.origin.name);
  }

//  for(Arc t: allArcs){
//    print(t.name + ":" + t.teamPlayers.size());
//    for(Player p : t.teamPlayers){
//      println("\t" + p.name);
//    }
//  }
}

//boolean sketchFullScreen() {
//  return true;
//}

