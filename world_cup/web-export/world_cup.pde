/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com
 
 Geoplacement based on Till Nagel's tutorial: 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html 
 --------------------------------------------------------------------------- */

int mm;

ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

ArrayList<Circle> allCircles;
ArrayList<Arc> allArcs;

PVector worldMapPos;
PVector worldMapSize;
PVector center;

//animation
int interval;
int transition1;
int transition2;
int transition3;
boolean showTutorial;

PFont archivoNarrow;
PFont archivoNarrowBold;
PFont bitter;
PFont bitterBold;
PShape galileu;
PShape diagram;

String selectedType; //"arc" or "circle"
Country selectedCountry;

void setup() {
  size(920, 1400);
  colorMode(HSB, 255, 255, 255);
  mm = 3;

  //JS font loading
  archivoNarrow = createFont("Archivo Narrow", 10);
  archivoNarrowBold = createFont("Archivo Narrow Bold", 10);
  bitter = createFont("Bitter", 10);
  bitterBold = createFont("Bitter Bold", 10);  

  //Processing font loading
//  archivoNarrow = createFont("ArchivoNarrow-Regular", 10);
//  archivoNarrowBold = createFont("ArchivoNarrow-Bold", 10);
//  bitter = createFont("Bitter-Regular", 10);
//  bitterBold = createFont("Bitter-Bold", 10);  
  
  galileu = loadShape("galileu.svg");
  diagram = loadShape("diagram.svg");

  center = new PVector(600, 350);

  //positioning "map"
  worldMapSize = new PVector(800, 420);
  worldMapPos = new PVector(center.x - worldMapSize.x/2 - 50, center.y - worldMapSize.y/2 + 65);

  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv");
  for (int i = 0; i < allCountries.size(); i++) {
    Country c = allCountries.get(i);
    c.setColor(i);
  }
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");

  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  //Players' positions in the arc will be based on this sorted list
  //  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  String[] sortedCountries = new String[allCountries.size()];
  for (int i = 0; i < allCountries.size(); i++) {
    sortedCountries[i] = allCountries.get(i).name;
  } 
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");  //Sorting the arcs

  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
  for (Arc a : allArcs) {
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

  selectedType = "";

  interval = 1000;
  transition1 = millis() + interval;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
  showTutorial = false;
}

void draw() {  
  background(255);

  PVector textPos = new PVector(20, 200);
  float leading = 13;  

  //Default/initial/show all
  if (selectedType.equals("") && millis() > transition1) {
    for (Arc a : allArcs) {
      if (millis() > transition2) {
        a.display();

        //Players
        for (Player p : a.teamPlayers) {
          p.display();
        }
      }
    }
  }

  //Arcs (selected)
  for (Arc a : allArcs) {
    a.display();

    //If "arc" is selected, draw players staring from arc  
    if (selectedType.equals("arc") && a.isActive) {

      fill(0);
      textAlign(LEFT);
      textFont(archivoNarrowBold);
      textSize(12);
      text(a.thisCountry.name.toUpperCase() + ": grupo " + a.thisCountry.group.toUpperCase(), textPos.x, textPos.y);
      textPos.y += leading;      

      for (Player p : a.teamPlayers) {
        if (p.isActive) {
          p.display();

          fill(100);
          textFont(archivoNarrow);
          textSize(12);
          text(p.name, textPos.x, textPos.y);
          text(p.club + " (" + p.current.abbreviation + ")", textPos.x + 100, textPos.y);
          textPos.y += leading;
        }
      }
    }
  }

  //Circles
  textPos = new PVector(20, 200);
  for (Circle c : allCircles) {
    //If "circle" is selected, draw players staring from circle
    if (selectedType.equals("circle") && c.isActive) {

      fill(0);
      textAlign(LEFT);
      textFont(archivoNarrowBold);
      textSize(12);      
      text(c.thisCountry.name.toUpperCase() + ": " + c.clubPlayers.size() + " jogadores", textPos.x, textPos.y);
      textPos.y += leading;

      for (Player p : c.clubPlayers) {
        p.display();

        fill(100);
        textFont(archivoNarrow);
        textSize(12);
        text(p.name, textPos.x, textPos.y);
        textAlign(CENTER);
        text(p.origin.abbreviation.toUpperCase(), textPos.x + 110, textPos.y);
        textAlign(LEFT);
        text(p.club, textPos.x + 130, textPos.y);
        textPos.y += leading;
      }
    }    
    c.update();
    c.display();
  }  

  if (showTutorial) {
    drawHowToRead();
  }
  else {
    drawHeader();
  }

  shape(galileu, 816, 668);
  shape(diagram, 848, 15);
  fill(100);
  textFont(archivoNarrowBold);
  textSize(13);
  textAlign(CENTER, TOP);
  text("COMO LER", 876, 81);
  }

  void mousePressed() {
    showTutorial = false;
    selectedType = "";
    for (Arc a : allArcs) {
      if (a.isHovering()) {
        if (!selectedType.equals("arc") && selectedCountry != a.thisCountry) {
          selectedType = "arc";
          selectedCountry = a.thisCountry;
          dimColors();
          a.isActive = true;

          for (Player p : a.teamPlayers) {
            p.isActive = true;
            p.currCountry.isActive = true;
          }
        }
        else {
          selectedType = "";
        }
      }
    }

    for (Circle c : allCircles) {
      if (c.isHovering()) {
        //If it' not already selected... Select!
        if (!selectedType.equals("circle") && selectedCountry != c.thisCountry) {
          selectedType = "circle";
          selectedCountry = c.thisCountry;
          dimColors();
          c.isActive = true;

          for (Player p : c.clubPlayers) {
            p.isActive = true;
            p.originCountry.isActive = true;
          }
        }
        else {
          selectedType = "";
        }
      }
    }
    if (selectedType.equals("")) {
      selectedCountry = null;
      restoreColors();
    }
  }

void mouseMoved() {
  boolean changeCursor = false;

  for (Arc a : allArcs) {
    if (a.isHovering()) {
      changeCursor = true;
      a.isOver = true;
    }
    else {
      a.isOver = false;
    }
  }   

  for (Circle c : allCircles) {
    color newColor = c.thisCountry.myColor;
    if (c.isHovering()) {
      changeCursor = true;
      c.isOver = true;
    }
    else {
      c.isOver = false;
    }
  }  

  if (changeCursor) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  }
}

void dimColors() {
  for (Arc a: allArcs) {
    a.isActive = false;
    for (Player p: a.teamPlayers) {
      p.isActive = false;
    }
  }  
  for (Circle c: allCircles) {
    c.isActive = false;
  }
}

void restoreColors() {
  for (Arc a: allArcs) {
    a.isActive = true;
    for (Player p: a.teamPlayers) {
      p.isActive = true;
    }
  }   
  for (Circle c: allCircles) {
    c.isActive = true;
  }
}

ArrayList<Country> initCountries(String filename) {
  ArrayList<Country> tempList = new ArrayList<Country>();
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    String abbreviation = trim(myLine[1]);
    String group = trim(myLine[2]);
    Country thisCountry = new Country(name, abbreviation, group);
    //      thisCountry.setColor();
    tempList.add(thisCountry);
    //      println(name + "\t" + abbreviation + "\t" + group);
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
      if (name.equals(c.name)) {
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

    Country origin = new Country("", "", "");
    for (Country c : allCountries) {
      if (originString.equals(c.name)) {
        origin = c;
        break;
      }
    }
    Country current = new Country("", "", "");
    for (Country c : allCountries) {
      if (currentString.equals(c.name)) {
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
  for (String s : sortedCountries) {
    s = trim(s);
  }  
  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {
    //Looping through each object
    for (int j = 0; j < thesePlayers.size(); j++) {
      String thisValue = "";
      if (criteria.equals("origin")) {
        thisValue = thesePlayers.get(j).origin.name;
      }
      else if (criteria.equals("current")) {
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

ArrayList<Arc> createArcs(ArrayList<Player> thesePlayers) {

  ArrayList<Arc> tempList = new ArrayList<Arc>();

  Country prevCountry = new Country("", "", "");
  ArrayList<Player> tempPlayers = new ArrayList<Player>();

  for (int i = 0; i < thesePlayers.size(); i++) {

    Player p = thesePlayers.get(i);

    //If the current player's country is different from the previous...
    if (!p.origin.name.equals(prevCountry.name)) {
      //If it is not the first player...
      if (i != 0) {
        //Create a new team based on the previous information
        tempList.add(new Arc(prevCountry, tempPlayers));
      } 
      //Cleaned the list up
      tempPlayers = new ArrayList();
    }
    //    if(p.origin.name.equals("Uruguai")){
    //      println(p.name + "\t" + p.current.name);
    //    }
    tempPlayers.add(p);

    //Wait! Was it the last player?
    if (i == thesePlayers.size() - 1) {
      tempList.add(new Arc(prevCountry, tempPlayers));
    }    

    prevCountry = p.origin;
  }
  return tempList;
}

ArrayList<Arc> setArcs(ArrayList<Arc> theseArcs) {

  ArrayList<Arc> tempList = theseArcs;
  float angleOffset = 0.005 * PI; //Distance between each arc

  //Filling the lower part in
  float radius = 315;
  float x = center.x;
  float y = center.y;
  float startAngle = 1.2 * PI;
  float endAngle = 0;
  float direction = 1;

  for (int i = 0; i < tempList.size(); i++) {
    Arc a = tempList.get(i);
    float arcLength = (1.2*PI - (tempList.size() - 1) * angleOffset) / tempList.size();

    endAngle = startAngle + arcLength * direction;

    if (startAngle < endAngle) {  //Upper arcs
      a.setArcParam(x, y, radius, startAngle, endAngle);
    }
    else {                      //Lower arcs
      a.setArcParam(x, y, radius, endAngle, startAngle);
    }

    startAngle = endAngle + angleOffset * direction;  //next

    //lower arcs
    if (i == tempList.size()/2 - 1) {
      startAngle -= PI;
      direction = -1;
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
  //    for(Player p : c.clubPlayers){
  //      println("\t" + p.name + " \t" + p.origin.name);
  //    }
  //  }  
  //  for (Player p : allPlayers) {
  //    if(p.origin.name.equals("Uruguai")){
  //      println(p.name + " \t" + p.origin.name + " \t" + p.current.name);
  //    }
  //  }

  //  for(Arc a: allArcs){
  //    if(a.thisCountry.name.equals("Uruguai")){
  //      print(a.thisCountry.name + ":" + a.teamPlayers.size());
  //      for(Player p : a.teamPlayers){
  //        println("\t" + p.name + "\t" + p.current.name);
  //      }
  //    }
  //  }
}

void drawHeader() {
  fill(100);
  textFont(archivoNarrow);
  textSize(42);
  textAlign(LEFT, TOP);
  PVector textPos = new PVector(18, 26);
  String msg = "Copa da Europa?";
  text(msg, textPos.x, textPos.y);

  textPos.y = 75;
  textFont(bitter);
  textSize(13);
  textLeading(15);
  msg = "Três em cada quatro convocados jogam em clubes europeus; veja de quais países eles saem para atuar em suas seleções e quais são os esquadrões com menos atletas jogando em casa";
  text(msg, textPos.x, textPos.y, 240, 200);
}

void drawHowToRead() {
  fill(255, 150);
  rect(0, 0, width, height);

  fill(0);
  textFont(archivoNarrow);
  textSize(15);
  textLeading(15);
  textAlign(LEFT);
  stroke(0);
  strokeWeight(1);  

  PVector textPos = new PVector(85, 90);
  PVector arrowPos = new PVector(0, 0);
  String msg = "Ao clicar nos círculos,\nmostra o NÚMERO DE\nJOGADORES que atuam\nna seleção indicada";
  text(msg, textPos.x, textPos.y);

  Arc a = allArcs.get(0);
  float angle = (a.endAngle + a.startAngle)/2;
  arrowPos.x = a.pos.x + cos(angle) * a.radius * 0.95;
  arrowPos.y = a.pos.y + sin(angle) * a.radius * 0.95;
  line(textPos.x + 130, textPos.y + 15, arrowPos.x, arrowPos.y);
  ellipse(arrowPos.x, arrowPos.y, 3, 3);

  pushMatrix();
  translate(arrowPos.x, arrowPos.y);
  rotate(angle + PI/2);  
  textFont(archivoNarrowBold);
  textSize(12);
  textAlign(CENTER, TOP);
  text("6", 0, 0);  
  popMatrix();

  Circle c = allCircles.get(5);
  textPos.y = c.pos.y;
  msg = "Ao clicar nas seleções, mostra a\nQUANTIDADE DE CONVOCADOS\nem atuação nos clubes do país";
  textFont(archivoNarrow);
  textSize(15);
  textLeading(15);
  textAlign(LEFT);  
  text(msg, textPos.x, textPos.y);

  arrowPos.x = c.pos.x - 15;
  arrowPos.y = c.pos.y + 15;  
  line(textPos.x + 200, textPos.y + 15, arrowPos.x, arrowPos.y);
  ellipse(arrowPos.x, arrowPos.y, 3, 3);
  textFont(archivoNarrowBold);
  textSize(12);
  textAlign(CENTER, TOP);
  text("122", c.pos.x, c.pos.y + 10);

  textPos.y = 570;
  textFont(archivoNarrow);
  textSize(15);
  textLeading(15);
  textAlign(LEFT);
  msg = "A área do círculo corresponde\nao NÚMERO DE CONVOCADOS\nque jogam nos clubes daquele país";
  text(msg, textPos.x, textPos.y);

  c = allCircles.get(2);
  arrowPos.x = c.pos.x;
  arrowPos.y = c.pos.y + c.radius;
  line(textPos.x + 190, textPos.y + 15, arrowPos.x, textPos.y + 15);
  line(arrowPos.x, textPos.y + 15, arrowPos.x, arrowPos.y);
  noFill();
  ellipse(arrowPos.x, arrowPos.y - c.radius, c.radius*2, c.radius*2);
}

void keyPressed() {
  showTutorial = true;
  selectedType = "";
  selectedCountry = null;
  restoreColors();
}

//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    teamPlayers = _teamPlayers;
    
    isOver = false;
    isActive = true;
  }

  void setArcParam(float _x, float _y, float _r, float _startAngle, float _endAngle){
    pos = new PVector(_x, _y);
    radius = _r;
    startAngle = _startAngle;
    endAngle = _endAngle;
  }  
  
  void linkCircles(){
    //Club country
    for (Circle c : allCircles) {
      for (Player p : teamPlayers) {
        if (p.current.name.equals(c.thisCountry.name)) {
          p.currCountry = c;
          c.totalPlayers ++;
          c.clubPlayers.add(p);
          
          p.originCountry = this;
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle, endAngle);   
      float offset = 40*mm;  //distance from arc to control point
      PVector p1 = new PVector(0,0);
      PVector p2 = new PVector(0,0);
      p1.x = pos.x + cos(angle) * (radius - 4*mm);
      p1.y = pos.y + sin(angle) * (radius - 4*mm);
      p2.x = pos.x + cos(angle) * (radius - 4*mm - offset);
      p2.y = pos.y + sin(angle) * (radius - 4*mm - offset);
      
      PVector p4 = p.currCountry.pos;
//      PVector p3 = PVector.lerp(p2, p4, 0.5);
      //lerp on a vector doesn't work in javaScript mode
      PVector p3 = new PVector(p2.x, p2.y);
      p3.x = lerp(p2.x, p4.x, 0.5);
      p3.y = lerp(p2.y, p4.y, 0.5);
  
      p.setPos(p1, p2, p3, p4);
      p.setAngle(angle);
    }
  }  
  
  boolean isHovering(){
    float mouseAngle = atan2(mouseY - center.y, mouseX - center.x);
    if(mouseAngle < 0) {
      mouseAngle = TWO_PI - abs(mouseAngle); 
    }
    float distance = dist(mouseX, mouseY, center.x, center.y); 
    if(startAngle < mouseAngle && mouseAngle < endAngle &&
       radius - 4*mm < distance && distance < radius + 4*mm){
      return true;
    }else{
      return false;
    }
  }
  
  void display(){
    //TRANSITION
    float currAngle = 0;
    float alpha = 0;
    if(millis() < transition2){
      currAngle = map(transition2 - millis(), interval, 0, startAngle, endAngle);
      currAngle = constrain(currAngle, 0, endAngle);
      alpha = map(transition2 - millis(), interval, 0, 0, 255);
      alpha = constrain(alpha, 0, 255);
    }else{
      currAngle = endAngle;
      alpha = 255;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      newColor = color(hue(newColor), saturation(newColor)*0.5, brightness(newColor));
    }
    if(!isActive){
      newColor = color(0, 0, 0, 30);
    }
    
    pushMatrix();
      translate(pos.x, pos.y);
      float arcWeight = 24;
      noFill();
      stroke(newColor);
      strokeWeight(arcWeight);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
      
        float direction = 1;
        if(angle < PI){
          direction *= -1;
        }
        rotate(angle + PI/2 * direction);
      
        rectMode(CORNER);
        textAlign(CENTER, CENTER);
        textFont(archivoNarrowBold);
        textSize(13);      
        fill(0, alpha);
        text(thisCountry.abbreviation.toUpperCase(), 0, 0);
        
        //NUMBER
        if(selectedType.equals("circle") && isActive){
          int nPlayers = 0;
          for(Player p : teamPlayers){
            if(p.isActive){
              nPlayers ++;
            }
          }
          
          noStroke();
          fill(newColor);
          rectMode(CENTER);
          rect(0, arcWeight * 0.8 * direction, 15, 15);
          fill(0);
          text(nPlayers, 0, arcWeight * 0.8 * direction);
          
        }        
        
    popMatrix();
  }
}
//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> clubPlayers;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0; 
    clubPlayers = new ArrayList<Player>();
   
    isOver = false;
    isActive = true;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);    
  }
  
  void setControlPoint(){
      float offset = 30*mm;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + finalRadius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + finalRadius + offset);  
  }
  
  void setRadius(int max){
    finalRadius = map(totalPlayers, 1, max, 6, 50);
    setControlPoint();    
  }
  
  void update(){
    float padding = 16; //space in between the circles
    for(Circle c : allCircles){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.5;
        pos.y += escape.y * 1.5;
        
        setControlPoint();        
      }    
    }  
  }  
  
  boolean isHovering(){
    if(dist(mouseX, mouseY, pos.x, pos.y) < radius){
      return true;
    }else{
      return false;
    }
  }

  void display() {
    //TRANSITION
    if(radius < finalRadius * 0.99){
      radius += (finalRadius - radius) * 1;
    }else{
      radius = finalRadius;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      //If it's NOT one of the "gray" countries...
      if(saturation(newColor) > 100){
        newColor = color(hue(newColor), saturation(newColor)*0.5, brightness(newColor));
      }else{
        newColor = color(hue(newColor), saturation(newColor), brightness(newColor) + 20);
      }
    }
    if(!isActive){
      newColor = color(0, 0, 0, 30);
    }    
    
    noStroke();  
    fill(newColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    if(isOver || isActive){
      float maxTextWidth = 42;
      float leading = 9;
      fill(0);
      textFont(archivoNarrow);
      textSize(10);
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      if(textWidth(thisCountry.name) < maxTextWidth){
        text(thisCountry.name, pos.x, pos.y);
      }else{
        String[] words = split(thisCountry.name, " ");
        String msg = "";
        for(int i = 0; i < words.length - 1; i++){
          msg += words[i] + " ";
        }
        text(msg, pos.x, pos.y - leading);
        msg = words[words.length - 1];
        text(msg, pos.x, pos.y);
      }
      
      //NUMBER
      if(!selectedType.equals("") && isActive){
        textFont(archivoNarrowBold);
        textSize(12);
        int nPlayers = 0;
        if(selectedType.equals("circle")){
          nPlayers = clubPlayers.size();
        
        }else if(selectedType.equals("arc")){
          for(Player p : clubPlayers){
            if(p.isActive){
              nPlayers ++;
            }
          }
        }
        text(nPlayers, pos.x, pos.y + leading + 2);
      }
    }
  }
}

//Do not draw
//Only a sort of HashMap to store countries x colors
class Country{
  String name;
  String abbreviation;
  String group;
  color myColor;
  
  Country(String _name, String _abbreviation, String _group){
    name = _name;
    abbreviation = _abbreviation;
    group = _group;
  }
  
  void setColor(int i){
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float hu = 0;
    float sa = 0;
    float br = 0;

//    //hue
    if(groupInt % 2 != 0){
      hu = map(groupInt, 96, 104, 100, 235);
      hu = hu + (i%4)*4;
    }else{
      hu = map(groupInt, 98, 104, 0, 55);
      hu = hu - (i%4)*2;
    }
    hu = constrain(hu, 0, 255);
    
    sa = 200;
    
    //Indigo blue
    if(140 < hu && hu < 200){
      sa -= 50;
      hu -= 5;
      if(hu > 160){
        sa -= 30;
      }
    }
       
    br = 255;
    
    if(groupInt < 97){  //gray
//      hu = 40;
//      sa = 90;
//      br = 130;
      hu = 40;
      sa = 90;
      br = 200;
    }
    myColor = color(hu, sa, br);
  }
}
//Draws lines
class Player {
  String name, club;
  Country origin, current;
  ArrayList<PVector> anchors;
  float angle;
  boolean isActive;  
  
  Circle currCountry;
  Arc originCountry;

  Player(String _name, Country _origin, String _club, Country _current) {
    name = _name;
    origin = _origin;
    club = _club;
    current = _current;
    anchors = new ArrayList<PVector>();
    isActive = true;
  }

  void setPos(PVector p1, PVector p2, PVector p3, PVector p4) {
    anchors.add(p1);
    anchors.add(p2);    
    anchors.add(p3); 
    anchors.add(p4);    
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display() {
    
    float alpha = 0;
    if(millis() < transition3){
      alpha = map(transition3 - millis(), interval, 0, 0, 100);
      alpha = constrain(alpha, 0, 100);
    }else{
      alpha = 100;
    }  
    
    //Line
    noFill();
    strokeWeight(0.3*mm);
    stroke(currCountry.thisCountry.myColor, alpha);
//    line(anchors.get(0).x, anchors.get(0).y, currCountry.pos.x, currCountry.pos.y);
    bezier(anchors.get(0).x, anchors.get(0).y, 
           anchors.get(1).x, anchors.get(1).y,
           anchors.get(2).x, anchors.get(2).y,
           anchors.get(3).x, anchors.get(3).y);
//    bezier(anchors.get(0).x, anchors.get(0).y, 
//           anchors.get(1).x, anchors.get(1).y,
//           currCountry.controlPoint.x, currCountry.controlPoint.y,
//           currCountry.pos.x, currCountry.pos.y);
  }
}


