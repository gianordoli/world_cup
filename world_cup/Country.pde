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

//    //hue
    if(groupInt % 2 != 0){
      h = map(groupInt, 96, 104, 100, 235);
      h += i%4 * 4;
    }else{
      h = map(groupInt, 98, 104, 0, 60);
      h -= i%4 * 2;
    }
    
    s = 255;
    
    //Indigo blue
    if(140 < h && h < 200){
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
