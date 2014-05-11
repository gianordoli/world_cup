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
  
  void setColor(int i){
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float h, s, b;
    //group int: "a" to "h"
//    if(i < 16 * 4){
//      h = map(groupInt, 97, 100, 0, 120);
//    }else{
//      h = map(groupInt, 101, 104, 130, 255);
//    }

    //hue
    if(groupInt % 2 == 0){
      h = map(groupInt, 98, 104, 0, 60);
      
    }else{
      h = map(groupInt, 96, 103, 115, 235);
    }
//    h += map(i % 4, 0, 3, 0, 20);
    
    //Saturation
    if(i < 4*4){
      s = map(i % 4, 0, 3, 255, 180);
//      b = map(i % 4, 0, 3, 235, 255);    
    }else{
      s = map(i % 4, 0, 3, 180, 255);
//      b = map(i % 4, 0, 3, 255, 235);
    }
//    s = 255;
    
    //Indigo blue
    if(140 < h && h < 190){
      s -= 100;
    }    
    
    b = 255;
    
    if(groupInt < 97){  //gray
      s = 0;
      b = 170;
    }
    myColor = color(h, s, b);  
  }
}
