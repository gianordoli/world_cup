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
    
    sa = 255;
    
    //Indigo blue
    if(140 < hu && hu < 200){
      sa -= 100;
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
