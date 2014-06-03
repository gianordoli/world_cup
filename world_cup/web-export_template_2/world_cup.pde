/* @pjs preload="galileu.svg, diagram.svg"; */ 

/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com
 
 Geoplacement based on Till Nagel's tutorial: 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html 
 --------------------------------------------------------------------------- */

color bgColor;
color labelColor;
color inactiveColor;

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
int transition4;
int showTutorial;
boolean showList;

PFont archivoNarrow;
PFont archivoNarrowBold;
PFont bitter;
PFont bitterBold;
PShape galileu;
PShape diagram;

String selectedType; //"arc" or "circle"
Country selectedCountry;

TextArea myTextArea;

void setup() {
  size(920, 700);
  colorMode(HSB, 255, 255, 255);

  bgColor = color(60);
  labelColor = color(150);
  inactiveColor = color(255, 80);

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
  myTextArea = new TextArea(20, 240, 220, 420);

  center = new PVector(620, 350);

  //positioning "map"
  worldMapSize = new PVector(780, 420);
  worldMapPos = new PVector(center.x - worldMapSize.x/2 - 40, center.y - worldMapSize.y/2 + 65);

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

  selectedType = "";

  interval = 1000;
  transition1 = millis() + 3*interval;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
  transition4 = transition3 + interval;
  showTutorial = 0;
  showList = false;
  
  debug();  
}

void draw() {  
  background(bgColor);

  PVector textPos = new PVector(20, 200);
  float leading = 13;  

  //Default/initial/show all
  if (selectedType.equals("") && millis() > transition1) {
  for(int i = 0; i < allArcs.size(); i++){
    Arc a = allArcs.get(i);
    a.display(i);
      if (millis() > transition2) {
        //Players
        for (Player p : a.teamPlayers) {
          p.display();
        }
        if (transition3 < millis() && millis() < transition4) {
          showTutorial = 1;
        }
      }
    }
  }
  
  //Players
  if (selectedType.equals("arc")){
    for(int i = 0; i < allArcs.size(); i++){
      Arc a = allArcs.get(i);  
      if (a.isActive) {      
        for (Player p : a.teamPlayers) {
          p.display();
        }
        if(showList){
          drawPlayersList(a.thisCountry, 0);
        }
      }
    }
  }else if(selectedType.equals("circle")){
    for (Circle c : allCircles) {
      if(c.isActive) {      
        for (Player p : c.clubPlayers) {
          p.display();
        }
        if(showList){
          drawPlayersList(c.thisCountry, c.clubPlayers.size());
        }        
      }      
    }
  }

  //Arcs (selected)
  if (!selectedType.equals("")){
    for(int i = 0; i < allArcs.size(); i++){
      Arc a = allArcs.get(i);
      a.display(i);
    }
  }

  //Circles
  for (Circle c : allCircles) {    
    c.update();
    c.display();
  }  

  //Tutorial?
  if (showTutorial > 0) {
    drawTutorial();
  }
  else if(millis() > transition4){
    drawHeader();
    drawLabels();
  }

  //Logo
  shape(galileu, 816, 668);
  
  //Tutorial
  shape(diagram, 852, 10);
  fill(255);
  textFont(archivoNarrowBold);
  textSize(13);
  textAlign(CENTER, TOP);
  text("COMO LER", 880, 76);
}

void mouseReleased() {
  
  //Have I just finished dragging my scrollbar? 
  //If yes, no need to mess with my selection.
  //If not, let's check what I am trying to select
    //Also, I need to check if not in "tutorial mode"
  if(!myTextArea.isDragging && showTutorial == 0){
    
    //Let's assume that I'll deselect everything anyway
    selectedType = ""; 
    Boolean click = false;
    
    //Checking arcs
    for (Arc a : allArcs) {
      
      //It looks like my mouse was over something when I pressed it!
      if (a.isHovering()) {
        
        //Ok, select this something — unless it is the smae thing I had before
        if (!selectedType.equals("arc") && selectedCountry != a.thisCountry) {
          selectedType = "arc";
          selectedCountry = a.thisCountry;
          dimColors();        
          a.isActive = true;
  
          for (Player p : a.teamPlayers) {
            p.isActive = true;
            p.currCountry.isActive = true;
          }
          showList = true;
          setTextArea();
          click = true;
        }
      }
    }
  
    //Checking circles
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
          showList = true;
          setTextArea();
          click = true;
        }
      }
      
      //I I went trhough it all and no selection was made,
      //I was really trying to deselect everything. So...
      if (!click) {
        selectedCountry = null;
        restoreColors();
        showList = false;      
      }      
    }
  }
  
  //TUTORIAL
  if(showTutorial > 0){
    Arc a = allArcs.get(16);
    selectedType = "arc";
    selectedCountry = a.thisCountry;
    dimColors();
    a.isActive = true;
    for (Player p : a.teamPlayers) {
      p.isActive = true;
      p.currCountry.isActive = true;
    }         
    showTutorial ++;    
    
    if(showTutorial > 2){
      showTutorial = 0;
      selectedCountry = null;
      restoreColors();
      showList = false;
      selectedType = "";
    }
  }
  
  if(852 < mouseX && mouseX < 852 + diagram.width &&
     15 < mouseY && mouseY < 15 + diagram.height){
      Circle c = allCircles.get(5);
      selectedType = "circle";
      selectedCountry = c.thisCountry;
      dimColors();
      c.isActive = true;
      for (Player p : c.clubPlayers) {
        p.isActive = true;
        p.originCountry.isActive = true;
      }         
      showTutorial = 1;
      showList = false;
  }  
  
  //Whatever I was doing, I' not dragging my scrollbar anymore!
  myTextArea.isDragging = false;  
}

void mousePressed(){ 
  if(myTextArea.isHovering()){
    myTextArea.isDragging = true;
  }
}

void mouseDragged(){
  myTextArea.drag();
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
  
  if(myTextArea.isHovering()){
    changeCursor = true;
  }

  //COMO LER
  if(852 < mouseX && mouseX < 852 + diagram.width &&
     15 < mouseY && mouseY < 15 + diagram.height + 20){
      changeCursor = true;
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

void setTextArea(){
  int nLines = 0;
  String[] col1 = new String[0];
  String[] col2 = new String[0]; 
  String[] col3 = new String[0];
  
  if(selectedType.equals("arc")){
    for (Arc a : allArcs) {  
      if (a.isActive) {
        for (Player p : a.teamPlayers) {
          if (p.isActive) {
            nLines ++;
            col1 = expand(col1, col1.length + 1);
            col2 = expand(col2, col2.length + 1);
            col1[col1.length - 1] = p.name;
            col2[col2.length - 1] = p.club + " (" + p.current.abbreviation + ")"; 
          }
        }
      }
    }
    
  }else if(selectedType.equals("circle")){

    for (Circle c : allCircles) {  
      if (c.isActive) {
        for (Player p : c.clubPlayers) {
          if (p.isActive) {
            nLines ++;
            col1 = expand(col1, col1.length + 1);
            col2 = expand(col2, col2.length + 1);
            col3 = expand(col3, col3.length + 1);
            col1[col1.length - 1] = p.name;
            col2[col2.length - 1] = p.origin.abbreviation.toUpperCase();
            col3[col3.length - 1] = p.club; 
          }
        }
      }
    }
  }  
//  printArray(col1);
//  printArray(col2);
  myTextArea.setText(col1, col2, col3);
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
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle + 0.003*PI, endAngle - 0.003*PI);   
      float offset = 120;  //distance from arc to control point
      PVector p1 = new PVector(0,0);
      PVector p2 = new PVector(0,0);
      p1.x = pos.x + cos(angle) * (radius - 12);
      p1.y = pos.y + sin(angle) * (radius - 12);
      p2.x = pos.x + cos(angle) * (radius - 12 - offset);
      p2.y = pos.y + sin(angle) * (radius - 12 - offset);
      
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
       radius - 12 < distance && distance < radius + 12){
      return true;
    }else{
      return false;
    }
  }
  
  void display(int i){
    //TRANSITION
    float currAngle = 0;
    float alpha = 0;
    if(millis() < transition2){
      currAngle = map(transition2 - millis(), interval, 0, startAngle, endAngle);
      currAngle = constrain(currAngle, 0, endAngle);
      alpha = map(transition1 - millis(), interval, 0, 0, 255);
      alpha = constrain(alpha, 0, 255);
    }else{
      currAngle = endAngle;
      alpha = 255;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      newColor = color(hue(newColor), saturation(newColor), brightness(newColor)*1.2);
    }
    if(!isActive){
      newColor = inactiveColor;
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
      float direction = 1;
      if(angle < PI){
        direction *= -1;
      }      
      
      if(i % 4 == 0){
        float titleAngle = 0;
        Arc lastArc = allArcs.get(i + 3);
        strokeWeight(1);
        stroke(thisCountry.myColor);
        if(direction > 0){
          arc(0, 0, radius*2 + arcWeight + 6, radius*2 + arcWeight + 6, startAngle, lastArc.endAngle);
          titleAngle = (startAngle + lastArc.endAngle)/2;
        }else{
          arc(0, 0, radius*2 + arcWeight + 6, radius*2 + arcWeight + 6, lastArc.startAngle, endAngle);
          titleAngle = (endAngle + lastArc.startAngle)/2;
        }
        translate(cos(titleAngle) * (radius + arcWeight), sin(titleAngle) * (radius + arcWeight));
        rotate(titleAngle + PI/2 * direction);
        fill(labelColor);
        textAlign(CENTER, CENTER);
        textFont(bitter);
        textSize(10);
        text("GRUPO " + thisCountry.group.toUpperCase(), 0, 0);
        
        //Undo!
        rotate(- (titleAngle + PI/2 * direction));        
        translate(-(cos(titleAngle) * (radius + arcWeight)), -(sin(titleAngle) * (radius + arcWeight)));
      }
      
      translate(cos(angle) * radius, sin(angle) * radius);
        
        rotate(angle + PI/2 * direction);
      
        rectMode(CORNER);
        textAlign(CENTER, CENTER);
        textFont(archivoNarrow);
        textSize(14);      
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
          rect(0, arcWeight * 0.8 * direction, 17, 20, 5);
          fill(0);
          textAlign(CENTER, CENTER);
          text(nPlayers, 0, (arcWeight - 5)*direction);
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
      float offset = 30;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + finalRadius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + finalRadius + offset);  
  }
  
  void setRadius(int max){
//    float area = map(totalPlayers, 1, max, 100, 5000);
    finalRadius = sqrt(totalPlayers/PI) * 7;
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
        pos.x += escape.x * 1.3;
        pos.y += escape.y * 1.3;
        
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
      radius += (finalRadius - radius) * 0.1;
    }else{
      radius = finalRadius;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      //If it's NOT one of the "gray" countries...
      if(saturation(newColor) > 100){
        newColor = color(hue(newColor), saturation(newColor), brightness(newColor)*1.2);
      }else{
        newColor = color(hue(newColor), saturation(newColor), brightness(newColor) + 20);
      }
    }
    if(!isActive){
      newColor = inactiveColor;
    }    
    
    noStroke();  
    fill(newColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    if(isOver || isActive){
      float maxTextWidth = 42;
      float leading = 9;
      fill(255);
      textFont(archivoNarrow);
      if(finalRadius > 10){
        textSize(11);
      }else{
        textSize(9.5);
      }
      
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
      hu = map(groupInt, 98, 104, 0, 55);
      hu = hu + (i%4)*2;
    }else{
      hu = map(groupInt, 96, 104, 100, 235);      
      hu = hu - (i%4)*4;
    }
    hu = constrain(hu, 0, 255);
    sa = 255;
    br = 225;
    
    //Indigo blue/purple
    if(140 < hu && hu < 200){
      sa -= 50;
      hu -= 5;
      if(hu > 160){
        sa -= 30;
      }
    }

    //Yellow/green
    if(30 < hu && hu < 140){
      br -= 30;
    }
    
    //Orange
    if(0 < hu && hu < 20){
      hu += 10;
    }    
    
    if(groupInt < 97){  //gray
      hu = 40;
      sa = 90;
      br = 120;
//      hu = 40;
//      sa = 90;
//      br = 200;
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
    strokeWeight(1);
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

class TextArea {
  
  PGraphics textRect;  //Mask. The text is drawn inside of it
  String[] col1;
  String[] col2;
  String[] col3;
  
  //These vars don't vary
  int areaX;           //Mask X
  int areaY;           //Mask y
  int areaWidth;       //Mask width
  int areaHeight;      //Mask height
  int leading;
  
  //These vars vary!
  float textY;         //Actual text area y
  float textHeight;    //Actual text area height. Needs to be calculated counting the rows
  float scrollbarY;    //Scrollbar changing coordinate;

  boolean isDragging;  //Checks if the scrollbar is being dragged
  boolean hasScroll;   //Checks if the text height is greater then the area, i.e., if it needs a scrollbar

//  TextArea(String[] tempText, int tempAreaX, int tempAreaY, int tempAreaWidth, int tempAreaHeight) {
  TextArea(int _areaX, int _areaY, int _areaWidth, int _areaHeight) {
    
    areaX = _areaX;
    areaY = _areaY;
    areaWidth = _areaWidth;
    areaHeight = _areaHeight;
    leading = 14;
    
    textRect = createGraphics(areaWidth, areaHeight);
  }
  
  //Calculates text height
  void setText(String[] _col1, String[] _col2, String[] _col3){
    
    col1 = _col1;
    col2 = _col2; 
    col3 = _col3;
 
    textHeight = col1.length * leading;
    if(textHeight > areaHeight){
      hasScroll = true;
    }else{
      hasScroll = false;
    }
 
    //Reset scroll!
    textY = 0;
    scrollbarY = areaY + 7;
    isDragging = false;  
  }  

  boolean isHovering(){
    if(scrollbarY - 7 < mouseY && mouseY < scrollbarY + 7
    && areaX + areaWidth < mouseX && mouseX < areaX + areaWidth + 14
    && hasScroll){
      return true;
    }else{
      return false;
    }
//    println(isDragging);    
  }
  
  void drag(){
    if(isDragging){
      scrollbarY = constrain(mouseY, areaY + 7, areaY + areaHeight - 7);
      textY = map(scrollbarY, areaY + 7, areaY + areaHeight - 7, 0, areaHeight - textHeight);
    }  
  }
  
  void scrollbar(){
    strokeWeight(2);
    stroke(labelColor, 100);
    noFill();
    line(areaX + areaWidth + 7, areaY, areaX + areaWidth + 6, areaY + areaHeight);
    
    noStroke();
    fill(labelColor);
    rectMode(CENTER);
    rect(areaX + areaWidth + 7, scrollbarY, 14, 14, 3);
  }

  void display() {

    if(hasScroll){
      scrollbar();
    }
    
    textRect.beginDraw();
    textRect.background(bgColor);
    textRect.fill(255);
    textRect.textFont(archivoNarrow);
    textRect.textSize(12);
    
    if(selectedType.equals("arc")){
      textRect.textAlign(LEFT, TOP);  
      for(int i = 0; i < col1.length; i++){
        textRect.text(col1[i], 0, textY + i*leading);
        textRect.text(col2[i], 110, textY + i*leading);
      }
    }else if(selectedType.equals("circle")){
      for(int i = 0; i < col1.length; i++){
        textRect.textAlign(LEFT, TOP);
        textRect.text(col1[i], 0, textY + i*leading);
        textRect.textAlign(CENTER, TOP);
        textRect.text(col2[i], 110, textY + i*leading);
        textRect.textAlign(LEFT, TOP);
        textRect.text(col3[i], 130, textY + i*leading);
      }
    }
    textRect.endDraw();    
    
    image(textRect, areaX, areaY);
  }
}
void drawHeader() {
  fill(255);
  textFont(archivoNarrow);
  textSize(42);
  textAlign(LEFT, TOP);
  PVector textPos = new PVector(18, 26);
  String msg = "Copa da Europa?";
  text(msg, textPos.x, textPos.y);

  textPos.y = 75;
  textFont(bitter);
  textSize(14);
  textLeading(17);
  msg = "Três em cada quatro convocados jogam em clubes europeus; veja de quais países eles saem para atuar em suas seleções e quais são os esquadrões com menos atletas jogando em casa";
  text(msg, textPos.x, textPos.y, 270, 200);    
}
void drawLabels(){
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(54);
  text("32", 344, 48);
  textFont(archivoNarrowBold);
  textSize(13);
  text("SELEÇÕES", 344, 80);
  
  noFill();
  stroke(255);
  strokeWeight(1);  
  arc(380, 65, 50, 50, -PI/2, 0);
  line(405, 65, 410, 60);
  line(405, 65, 400, 60);  
  
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bitterBold);
  textSize(30);
  text("354", 290, 350);
  textFont(archivoNarrowBold);
  textSize(11);
  text("CLUBES DE", 290, 373);
  textFont(bitterBold);
  textSize(52);
  text("53", 290, 400);
  textFont(archivoNarrowBold);
  textSize(19);
  text("PAÍSES", 288, 435);
  
  stroke(255);
  strokeWeight(1);
  line(320, 395, 340, 395);
  line(340, 395, 335, 390);
  line(340, 395, 335, 400);
}
void drawPlayersList(Country c, int nPlayers){
  
  myTextArea.display();
  
  rectMode(CORNER);
  
  noStroke();
  fill(labelColor);
  rect(105, 186, 60, 14, 5, 5, 0, 0);
  fill(bgColor);
  textFont(archivoNarrowBold);
  textSize(10.5);
  textAlign(CENTER, CENTER);
  if(selectedType.equals("arc")){
    text("SELEÇÃO", 135, 193);
  }else if(selectedType.equals("circle")){
    text("PAÍS", 135, 193);
  }
  
  stroke(labelColor);
  strokeWeight(1);
  line(20, 200, 253, 200);
  line(20, 230, 253, 230);
  if(!myTextArea.hasScroll){
    line(20, myTextArea.areaY + myTextArea.textHeight + 15, 253, myTextArea.areaY + myTextArea.textHeight + 15);
  }else{
    line(20, myTextArea.areaY + myTextArea.areaHeight + 15, 253, myTextArea.areaY + myTextArea.areaHeight + 15);
  }
  
  noStroke();
  fill(c.myColor);
  rect(20, 204, 233, 22);
  
  fill(255);
  textAlign(LEFT, CENTER);
  textFont(archivoNarrowBold);
  textSize(13);
  if(selectedType.equals("arc")){
    text(c.name.toUpperCase() + " - GRUPO " + c.group.toUpperCase(), 24, 215);
  }else if(selectedType.equals("circle")){
    text(c.name.toUpperCase() + ": " + nPlayers + " jogadores", 24, 215);
  }
}
void drawTutorial() {
  
  //Alpha layer
  float alpha = 0;
  if(millis() < transition4){
    alpha = map(transition4 - millis(), interval, 0, 0, 100);
    alpha = constrain(alpha, 0, 100);
    fill(bgColor, alpha);
    rect(0, 0, width, height);    
  }else{
    alpha = 80;
    fill(bgColor, alpha);
    rect(0, 0, width, height);

  //Presets
    color tutorialColor = color(40, 255, 255);
    PVector textPos = new PVector(60, 50);
    PVector arrowPos = new PVector(0, 0);
    String msg = "";
    
    /*---------- FIRST SCREEN ----------*/
    if(showTutorial == 1){
      fill(tutorialColor);
      textFont(archivoNarrow);
      textSize(15);
      textLeading(15);
      textAlign(LEFT);
      stroke(tutorialColor);
      strokeWeight(1);  
      msg = "Os CÍRCULOS mostram os\npaíses dos clubes onde os\nconvocados atuam. Ao clicar\nneles, você descobre:";
      text(msg, textPos.x, textPos.y);
    
      textPos.y += 80;
      msg = "1. Quantos jogadores atuando\nnaquele país pertencem a\ncada uma das seleções";
      text(msg, textPos.x, textPos.y);
    
      Arc a = allArcs.get(0);
      float angle = (a.endAngle + a.startAngle)/2;
      arrowPos.x = a.pos.x + cos(angle) * a.radius * 0.96;
      arrowPos.y = a.pos.y + sin(angle) * a.radius * 0.96;
      line(textPos.x + 150, arrowPos.y, arrowPos.x, arrowPos.y);
      ellipse(arrowPos.x, arrowPos.y, 3, 3);
      
      textPos.y += 80;
      msg = "2. O NÚMERO e a\nÁREA DO CÍRCULO\nindicam o total de\nconvocados atuando ali";
      text(msg, textPos.x, textPos.y);
    
      Circle c = allCircles.get(5);
      
      arrowPos.x = c.pos.x - 15;
      arrowPos.y = c.pos.y + 15;  
      line(textPos.x + 150, arrowPos.y, arrowPos.x, arrowPos.y);
      ellipse(arrowPos.x, arrowPos.y, 3, 3);  
      noFill();
    
      arrowPos.x = c.pos.x;
      arrowPos.y = c.pos.y + c.radius;  
      ellipse(arrowPos.x, arrowPos.y - c.radius, c.radius*2, c.radius*2);
    }
    
    
    /*---------- SECOND SCREEN ----------*/
    else{
      textPos = new PVector(60, 500);    
      fill(tutorialColor);
      textFont(archivoNarrow);
      textSize(15);
      textLeading(15);
      textAlign(LEFT);
      stroke(tutorialColor);
      strokeWeight(1);    
      msg = "As siglas mostram\nas seleções nacionais.\nClicar nelas evidencia\nos países onde os\nconvocados atuam";
      text(msg, textPos.x, textPos.y);
  
      Arc a = allArcs.get(16);
      float angle = (a.endAngle + a.startAngle)/2;
      arrowPos.x = a.pos.x + cos(angle) * a.radius * 1.05;
      arrowPos.y = a.pos.y + sin(angle) * a.radius * 1.05;
      line(textPos.x + 130, arrowPos.y, arrowPos.x, arrowPos.y);
      ellipse(arrowPos.x, arrowPos.y, 3, 3);
  
      textPos.y += 120;
      msg = "Este NÚMERO agora indica\na quantidade de convocados\ndaquela seleção atuando em\ncada um dos países";
      text(msg, textPos.x, textPos.y);
      
      Circle c = allCircles.get(3);
      arrowPos.x = c.pos.x;
      arrowPos.y = c.pos.y + 25;  
      line(textPos.x + 180, textPos.y, arrowPos.x, textPos.y);    
      line(arrowPos.x, textPos.y, arrowPos.x, arrowPos.y);    
      ellipse(arrowPos.x, arrowPos.y, 3, 3);
    }    
  }  
}

