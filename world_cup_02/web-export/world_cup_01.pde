//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;
String[] sortedCountries;

PShape worldMap;
PVector worldMapPos;
PVector worldMapSize;

void setup(){
//  JS:
  size(1212, 798);
//  size(404*mm, 266*mm);
  colorMode(HSB);
//  beginRecord(PDF, "world_cup.pdf");

  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapPos = new PVector(30*mm, 70*mm);
  worldMapSize = new PVector(width - 100*mm, height - 100*mm);

//  sortedCountries = loadStrings("countries_visual_sorting.txt");
  sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  for(int i =0; i < sortedCountries.length; i++){
    sortedCountries[i] = trim(sortedCountries[i]);
  }  
  
  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();
  loadPlayers("players.tsv");
  loadCountriesCoordinates("coordinates_pt.tsv");
  setCountriesColors();  
  sortPlayersCountry();
  sortPlayersClub();
  setPlayersPositionsAndColors();
//  debug();
}

void draw(){
  background(255);
  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);
  
  for (Country c : allCountries) {
    c.display();
  }
  
  for (int i = 0; i < allPlayers.size(); i++) {
    Player p = allPlayers.get(i);
    p.display(allPlayers, i);
  }  

//  endRecord();
//  exit();
}

void loadPlayers(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    allPlayers.add(new Player(trim(myLine[1]), trim(myLine[0]), trim(myLine[2]), trim(myLine[3])));
  }
}

void loadCountriesCoordinates(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    Country myCountry = new Country(name, lat, lng);
    allCountries.add(myCountry);
  } 
}

void setCountriesColors(){
  for(int i = 0; i < allCountries.size(); i++){
    Country c = allCountries.get(i);
    float h = map(i, 0, allCountries.size() - 1, 0, 255);
    float s = 255;
    float b = (i % 2 == 0) ? (255) : (150);
    c.setColor(h, s, b);
  }
}

void sortPlayersCountry(){
  
  //This temporary ArrayList will store the objects sorted
  ArrayList<Player> tempList = new ArrayList<Player>();  
  
  //Looping through each sorted value
  for(int i = 0; i < sortedCountries.length; i++){
    
    //Looping through each object
    for(int j = 0; j < allPlayers.size(); j++){
      String thisValue = allPlayers.get(j).country;
//        println("\t" + thisValue);
      
      //If the sorted value is found...
      if(sortedCountries[i].equals(thisValue)){
        //Add the object to the temporary list
        tempList.add(allPlayers.get(j));
      }
    }
  }
  
  //Replace the original list with the sorted one
  allPlayers = tempList;
}

void sortPlayersClub(){
  //New list
  ArrayList<Player> tempList = new ArrayList<Player>();
  
  int a = 0;
  
  while(a < allPlayers.size() - 1){
    //Current country
    ArrayList<Player> tempListCountry = new ArrayList<Player>();
    int i = a;
    String currCountry = allPlayers.get(a).country;
    while(currCountry.equals(allPlayers.get(i).country) && i < allPlayers.size() - 1){
      tempListCountry.add(allPlayers.get(i));
      i++;
    }
    if(i == allPlayers.size() - 1){
      tempListCountry.add(allPlayers.get(i));
    }
//    i--;
  //  for(Player p : tempListCountry){
  //    println(p.country + "\t" + p.clubCountry);
  //  }  
  
    for(int j = 0; j < sortedCountries.length; j++){
      for(int k = 0; k < tempListCountry.size(); k++){
        Player p = tempListCountry.get(k);      
        if(sortedCountries[j].equals(p.clubCountry)){
          tempList.add(p);
//          allPlayers.remove(p);
        }
      }
    }   
    a = i;
//    println(a);
  }
  
  for(Player p : tempList){
    println(p.country + "\t" + p.clubCountry);
  } 
 allPlayers = tempList; 
}

void setPlayersPositionsAndColors(){
  PVector center = new PVector(width/2, height/2);
  float radius = 120*mm;
  
  for(int i = 0; i < allPlayers.size(); i++){
    
    Player thisPlayer = allPlayers.get(i);

    //ARC (team)
    //Position    
//      float angle = map(i, 0, allPlayers.size() - 1, 0.75 * PI, 1.75 * PI);
    float angle = map(i, 0, allPlayers.size(), 0, 2 * PI);
//      if(angle > 1.25 * PI){
//        angle += 0.5 * PI;
//      }
    float x1 = center.x + cos(angle) * radius;
    float y1 = center.y + sin(angle) * radius;
    color countryColor = 0;    
    
    //Color
    for(int j = 0; j < allCountries.size(); j++){
      Country thisCountry = allCountries.get(j);
      if(thisPlayer.country.equals(thisCountry.name)){
        countryColor = thisCountry.myColor;
//          println(thisCountry.name);
        break;
      }
    }

    //ORIGIN (club)
    //position and color
    float x2 = 0;
    float y2 = 0;
    color clubCountryColor = 0;
    
    for(int j = 0; j < allCountries.size(); j++){
      Country thisCountry = allCountries.get(j);
      if(thisPlayer.clubCountry.equals(thisCountry.name)){
        x2 = thisCountry.pos.x;
        y2 = thisCountry.pos.y;
        clubCountryColor = thisCountry.myColor;
        break;
      }
    }
    
//    println(countryColor + ", " + clubCountryColor);  
    thisPlayer.setPos(x1, y1, x2, y2);
    thisPlayer.setColor(countryColor, clubCountryColor);
    thisPlayer.setAngle(angle);
  }
}

void debug(){
  for(Player p : allPlayers){
    println(p.name + "\t" + p.country + "\t" + p.club + "\t" + p.clubCountry + "\t" + p.start + "\t" + p.end); 
  }
}
class Country {

  String name;
  PVector pos;
  color myColor;

  Country(String _name, float lat, float lng) {
    name = _name;
    pos = new PVector();
    setPos(lat, lng);
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);       
  }
  
  void setColor(float h, float s, float b){
    myColor = color(h, s, b);
  }

  void display() {
    
    noStroke();
    fill(myColor);
    ellipse(pos.x, pos.y, 5, 5);
    
    float boxWidth = textWidth(name) + 4;
    fill(myColor, 150);
    rect(pos.x, pos.y, boxWidth, - 12);
    fill(255);
    textSize(10);
    textAlign(LEFT, BOTTOM);
    text(name, pos.x + 2, pos.y);
  }
}

class Player {
  String name, country, club, clubCountry;
  PVector start, end;
  float angle;
  color countryColor;
  color clubCountryColor;

  Player(String _name, String _country, String _club, String _clubCountry) {
    name = _name;
    country = _country;
    club = _club;
    clubCountry = _clubCountry;
    start = new PVector();
    end = new PVector();
  }

  void setPos(float x1, float y1, float x2, float y2) {
    start.x = x1;
    start.y = y1;
    end.x = x2;
    end.y = y2;
  }

  void setColor(color _countryColor, color _clubCountryColor) {
    countryColor = _countryColor;
    clubCountryColor = _clubCountryColor;
//    println(countryColor + ", " + clubCountryColor);
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display(ArrayList<Player> myList, int index) {
    noFill();
    stroke(clubCountryColor, 100);
    line(start.x, start.y, end.x, end.y);

    fill(countryColor);
    noStroke();
    ellipse(start.x, start.y, 5, 5);
    
    //Contry name
    if(index > 0 && !myList.get(index - 1).country.equals(country)){
      pushMatrix();
        translate(start.x, start.y);
        
        if(PI/2 < angle && angle < 1.5 * PI ){
          rotate(angle - PI);
          fill(0);
          textAlign(RIGHT, CENTER);
          text(country, -2*mm, 0);
        }else{
          rotate(angle);
          fill(0);
          textAlign(LEFT, CENTER);
          text(country, 2*mm, 0);
        }
      popMatrix();    
    }
  }
}


