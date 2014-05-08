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

  frameRate(30);

  //Loading and positioning map
  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapPos = new PVector(30*mm, 70*mm);
  worldMapSize = new PVector(width - 100*mm, height - 100*mm);

  //Initializing ArrayLists  
  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();

  //Loading and parsing countries list
  sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  for(int i =0; i < sortedCountries.length; i++){
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
  setPlayersPositions();
  
  //Linking the 2 ArrayLists
  linkPlayersAndCoutries();
//  debug();
}

void draw(){
  background(255);
//  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);

  for (int i = 0; i < allPlayers.size(); i++) {
    Player p = allPlayers.get(i);
    p.display(allPlayers, i);
  }  
  
  for (Country c : allCountries) {
    c.update();
    c.display();
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
    float b = (i % 2 == 0) ? (240) : (150);
//    float b = 200;
    c.setColor(h, s, b);
  }
}

void setCountriesRadii(){
  for(Country c : allCountries){
    for(Player p : allPlayers){
      if(p.clubCountry.equals(c.name)){
        c.totalPlayers ++;
      }
    }
  }
  
  int maxPlayers = getMax(allCountries);
  for(Country c : allCountries){
//    println(c.name + "\t" + c.totalPlayers);
    c.setRadius(maxPlayers);
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
  
  allPlayers = tempList; 
}

void setPlayersPositions(){
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
      
    thisPlayer.setPos(x1, y1);
    thisPlayer.setAngle(angle);
  }
}

void linkPlayersAndCoutries(){
  //Original country
  for(Country c : allCountries){
    for(Player p : allPlayers){
      if(p.country.equals(c.name)){
        p.originCountry = c;
      }
    }
  }  
  
  //Club country
  for(Country c : allCountries){
    for(Player p : allPlayers){
      if(p.clubCountry.equals(c.name)){
        p.currCountry = c;
      }
    }
  }
}

int getMax(ArrayList<Country> myList){
  int max = 0;
  for(Country c : myList){
    if(c.totalPlayers > max){
      max = c.totalPlayers;
    }
  }
  return max;
}

void debug(){
  for(Player p : allPlayers){
//    println(p.name + "\t" + p.country + "\t" + p.club + "\t" + p.clubCountry + "\t" + p.start + "\t" + p.end); 
  }
}
class Country {

  String name;
  PVector pos;
  float radius;
  float final_radius;
  int totalPlayers;  
  color myColor;

  Country(String _name, float lat, float lng) {
    name = _name;
    pos = new PVector();
    setPos(lat, lng);
    radius = 1;
    final_radius = random(10, 20);
    totalPlayers = 0;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);       
  }
  
  void setColor(float h, float s, float b){
    myColor = color(h, s, b);
  }
  
  void setRadius(int max){
    final_radius = map(totalPlayers, 0, max, 10, 40);
  }
  
  void update(){
    float padding = 2*mm; //space in between the circles
    for(Country c : allCountries){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.2;
        pos.y += escape.y * 1.2;
      }    
    }  
  }  

  void display() {
    
    if(radius < final_radius * 0.99){
      radius += (final_radius - radius) * 0.1;
    }
    
    noStroke();
    fill(myColor, 150);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
//    float boxWidth = textWidth(name) + 4;
//    fill(myColor, 150);
//    rect(pos.x, pos.y, boxWidth, - 12);
//    fill(255);
    fill(0);
    textSize(10);
    textAlign(CENTER, TOP);
    textLeading(10);
    text(name, pos.x - 10*mm, pos.y, 20*mm, 20*mm);
  }
}

class Player {
  String name, country, club, clubCountry;
  PVector arcPos;
  float angle;
  
  Country originCountry;
  Country currCountry;

  Player(String _name, String _country, String _club, String _clubCountry) {
    name = _name;
    country = _country;
    club = _club;
    clubCountry = _clubCountry;
    arcPos = new PVector();
  }

  void setPos(float x1, float y1) {
    arcPos.x = x1;
    arcPos.y = y1;
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display(ArrayList<Player> myList, int index) {
    //Line
    noFill();
    stroke(currCountry.myColor, 100);
    line(arcPos.x, arcPos.y, currCountry.pos.x, currCountry.pos.y);

    //Ellipse
    fill(originCountry.myColor);
    noStroke();
    ellipse(arcPos.x, arcPos.y, 5, 5);
    
    //Contry name
    if(index > 0 && !myList.get(index - 1).country.equals(country)){
      pushMatrix();
        translate(arcPos.x, arcPos.y);
        
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


