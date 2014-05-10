import processing.pdf.*;
boolean record = false;

int mm = 3;
ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;
String[] sortedCountries;

PShape worldMap;
PVector worldMapPos;
PVector worldMapSize;
PVector center;

PImage layout;

void setup() {
  //  JS:
  //  size(1212, 798);
  size(266*mm, 404*mm);
  colorMode(HSB);
//  frameRate(30);

  center = new PVector(width/2, height/2 + 13*mm);
  
  layout = loadImage("GA275_numeralhaCopa.png");  

  //Loading and positioning map
  worldMap = loadShape("world_map_equirectangular.svg");
//  worldMapPos = new PVector(70*mm, 90*mm);
  worldMapSize = new PVector(worldMap.width + 80*mm, worldMap.height + 80*mm);
  worldMapPos = new PVector((width - worldMapSize.x)/2 - 5*mm, (height - worldMapSize.y)/2 + 50*mm);
//  worldMap.disableStyle();

  //Initializing ArrayLists  
  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();

  //Loading and parsing countries list
  sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  for (int i =0; i < sortedCountries.length; i++) {
    sortedCountries[i] = trim(sortedCountries[i]);
  }  

  //Loading players
  loadPlayers("players.tsv");

  //Loading countries coordinates
  loadCountriesCoordinates("coordinates_pt.tsv");
  setCountriesColors();
  setCountriesRadii();

  //Setting players attributes
  sortPlayersCountry();
  sortPlayersClub();

  //Linking the 2 ArrayLists
  linkPlayersAndCoutries();  

  //Setting arc points
  setPlayersPositions();

  //  debug();
}

void draw() {
  if(record){
      beginRecord(PDF, "world_cup.pdf");
  }
  
  background(255);
//  image(layout, 0, 0, width, height);
//  fill(0, 10);
  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);

  for (int i = 0; i < allPlayers.size(); i++) {
    Player p = allPlayers.get(i);
    p.display(allPlayers, i);
  }  

  for (Country c : allCountries) {
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

void loadPlayers(String filename) {
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    allPlayers.add(new Player(trim(myLine[1]), trim(myLine[0]), trim(myLine[2]), trim(myLine[3])));
  }
}

void loadCountriesCoordinates(String filename) {
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    Country myCountry = new Country(name, lat, lng);
    allCountries.add(myCountry);
  }
}

void setCountriesColors() {
  for (int i = 0; i < allCountries.size(); i++) {
    Country c = allCountries.get(i);
    float h = map(i, 0, allCountries.size() - 1, 0, 200);
    float s = 255;
    //    float b = (i % 2 == 0) ? (255) : (200);
    float b = 255;
    c.setColor(h, s, b);
  }
}

void setCountriesRadii() {
  for (Country c : allCountries) {
    for (Player p : allPlayers) {
      if (p.clubCountry.equals(c.name)) {
        c.totalPlayers ++;
      }
    }
  }

  int maxPlayers = getMax(allCountries);
  for (Country c : allCountries) {
    //    println(c.name + "\t" + c.totalPlayers);
    c.setRadius(maxPlayers);
  }
}

void sortPlayersCountry() {

  //This temporary ArrayList will store the objects sorted
  ArrayList<Player> tempList = new ArrayList<Player>();  

  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {

    //Looping through each object
    for (int j = 0; j < allPlayers.size(); j++) {
      String thisValue = allPlayers.get(j).country;
      //        println("\t" + thisValue);

      //If the sorted value is found...
      if (sortedCountries[i].equals(thisValue)) {
        //Add the object to the temporary list
        tempList.add(allPlayers.get(j));
      }
    }
  }

  //Replace the original list with the sorted one
  allPlayers = tempList;
}

void sortPlayersClub() {
  //New list
  ArrayList<Player> tempList = new ArrayList<Player>();

  int a = 0;

  while (a < allPlayers.size () - 1) {
    //Current country
    ArrayList<Player> tempListCountry = new ArrayList<Player>();
    int i = a;
    String currCountry = allPlayers.get(a).country;
    while (currCountry.equals (allPlayers.get (i).country) && i < allPlayers.size() - 1) {
      tempListCountry.add(allPlayers.get(i));
      i++;
    }
    if (i == allPlayers.size() - 1) {
      tempListCountry.add(allPlayers.get(i));
    }
    //    i--;
    //  for(Player p : tempListCountry){
    //    println(p.country + "\t" + p.clubCountry);
    //  }  

    for (int j = 0; j < sortedCountries.length; j++) {
      for (int k = 0; k < tempListCountry.size(); k++) {
        Player p = tempListCountry.get(k);      
        if (sortedCountries[j].equals(p.clubCountry)) {
          tempList.add(p);
          //          allPlayers.remove(p);
        }
      }
    }   
    a = i;
    //    println(a);
  }

  allPlayers = tempList;
}

void setPlayersPositions() { 
  float radius = 137*mm;
  float centerOffset = 5*mm;

  for (int i = 0; i < allPlayers.size(); i++) {

    Player thisPlayer = allPlayers.get(i);

    //ARC (team)
    //Position    
    float angle = map(i, 0, allPlayers.size() - 1, 0.15 * PI, 1.55 * PI);
//    float angle = map(i, 0, allPlayers.size(), 0, 2 * PI);
      if(angle > 0.85 * PI){
        angle += 0.3 * PI;
        centerOffset = -5*mm;
      }
    float offset = 30*mm;  //distance from arc to control point
    float x1 = center.x + cos(angle) * radius;
    float y1 = center.y + centerOffset + sin(angle) * radius;
    float x2 = center.x + cos(angle) * (radius - offset);
    float y2 = center.y + centerOffset + sin(angle) * (radius - offset);    

    thisPlayer.setPos(x1, y1, x2, y2);
    thisPlayer.setAngle(angle);
  }
}

void linkPlayersAndCoutries() {
  //Original country
  for (Country c : allCountries) {
    for (Player p : allPlayers) {
      if (p.country.equals(c.name)) {
        p.originCountry = c;
      }
    }
  }  

  //Club country
  for (Country c : allCountries) {
    for (Player p : allPlayers) {
      if (p.clubCountry.equals(c.name)) {
        p.currCountry = c;
      }
    }
  }
}

int getMax(ArrayList<Country> myList) {
  int max = 0;
  for (Country c : myList) {
    if (c.totalPlayers > max) {
      max = c.totalPlayers;
    }
  }
  return max;
}

void debug() {
  for (Player p : allPlayers) {
    //    println(p.name + "\t" + p.country + "\t" + p.club + "\t" + p.clubCountry + "\t" + p.start + "\t" + p.end);
  }
}

