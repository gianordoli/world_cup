//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector size;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;

  ArrayList<Player> teamPlayers;
  
  float start, barLength;
  
  Country thisCountry;

  Circle(Country _thisCountry) {
    thisCountry = _thisCountry;
    pos = new PVector();
    size = new PVector();
    controlPoint = new PVector();
    totalPlayers = 0;  
    
    teamPlayers = new ArrayList<Player>();
  }
  
  void setCircleParam(float _start, float _barLength){
    pos = new PVector(_start, 50*mm);
    size = new PVector(_barLength, 5*mm); 

    float offset = 100*mm;
    controlPoint.x = pos.x;
    controlPoint.y = pos.y + offset;        
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float x = map(i, -1, teamPlayers.size(), pos.x, pos.x + size.x);
      
      float offset = 100*mm;  //distance from arc to control point
      float x1 = x;
      float y1 = pos.y + offset;
      float x2 = x;
      float y2 = pos.y;
  
      p.setPos(x1, y1, x2, y2);
    }
  } 
 
 void createConnections(){
   
  Country prevCountry = new Country("", "");
  ArrayList<Player> tempList = new ArrayList<Player>();
  
  for(int i = 0; i < teamPlayers.size(); i++){
    
    Player p = teamPlayers.get(i);
    
    //If the current player's country is different from the previous...
    if(!p.origin.name.equals(prevCountry.name)){
      //If it is not the first player...
      if(i != 0){
        //CREATE CONNECTION
        color myColor = thisCountry.myColor;
        float strokeLength = map(tempList.size(), 0, teamPlayers.size()+2, 0, size.x);        
        float x1 = (tempList.get(0).anchors.get(0).x + tempList.get(tempList.size()-1).anchors.get(0).x)/2; 
        float y1 = tempList.get(0).anchors.get(0).y;
        float x2 = (tempList.get(0).anchors.get(1).x + tempList.get(tempList.size()-1).anchors.get(1).x)/2; 
        float y2 = tempList.get(0).anchors.get(1).y;
        
        float x3 = (tempList.get(0).anchors.get(2).x + tempList.get(tempList.size()-1).anchors.get(2).x)/2; 
        float y3 = tempList.get(0).anchors.get(2).y;
        float x4 = (tempList.get(0).anchors.get(3).x + tempList.get(tempList.size()-1).anchors.get(3).x)/2; 
        float y4 = tempList.get(0).anchors.get(3).y;
        allConnections.add(new Connection(myColor, strokeLength, x1, y1, x2, y2, x3, y3, x4, y4));
      } 
      //Cleaned the list up
      tempList = new ArrayList();
    }
    
    tempList.add(p);
    
    //Wait! Was it the last player?
    if(i == teamPlayers.size() - 1){
      //CREATE CONNECTION 
        color myColor = thisCountry.myColor;
        float strokeLength = map(tempList.size(), 0, teamPlayers.size()+2, 0, size.x);        
        float x1 = (tempList.get(0).anchors.get(0).x + tempList.get(tempList.size()-1).anchors.get(0).x)/2; 
        float y1 = tempList.get(0).anchors.get(0).y;
        float x2 = (tempList.get(0).anchors.get(1).x + tempList.get(tempList.size()-1).anchors.get(1).x)/2; 
        float y2 = tempList.get(0).anchors.get(1).y;
        
        float x3 = (tempList.get(0).anchors.get(2).x + tempList.get(tempList.size()-1).anchors.get(2).x)/2; 
        float y3 = tempList.get(0).anchors.get(2).y;
        float x4 = (tempList.get(0).anchors.get(3).x + tempList.get(tempList.size()-1).anchors.get(3).x)/2; 
        float y4 = tempList.get(0).anchors.get(3).y;
        allConnections.add(new Connection(myColor, strokeLength, x1, y1, x2, y2, x3, y3, x4, y4));
    }    
    
    prevCountry = p.origin;    
  } 
 } 

  void display(int i) {
    
    noStroke();
    fill(thisCountry.myColor);
    rect(pos.x, pos.y, size.x, -size.y);
    


   rectMode(CORNER);
    textAlign(CENTER, BOTTOM);
    textFont(glober);       
   textSize(7);    
      textLeading(7.5);
    fill(0); 
    float offset = (i % 6) * 5*mm;    
    text(thisCountry.name, pos.x - 7*mm, pos.y - size.y - offset - 10*mm, size.x + 14*mm, 10*mm);     
  }
}

