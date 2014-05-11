//Do not draw
//Only a sort of HashMap to store countries x colors
class Country{
  String name;
  String group;
  color myColor;
  
  Country(String _name, String _group){
    name = _name;
    group = _group;
  }
  
  void setColor(){
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float h, s, b;
    //group int: "a" to "h"
    h = map(groupInt, 97, 104, 0, 255);
    if(groupInt < 97){
      s = 0;
      b = 170;
    }else{
      s = 225;
      b = 255;    
    }
    myColor = color(h, s, b);  
  }
}
