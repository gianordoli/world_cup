//Do not draw
//Only a sort of HashMap to store countries x colors
class Country{
  String name;
//  String group;
  String continent;
  color myColor;
  
  Country(String _name, String _continent){
    name = _name;
//    group = _group;
    continent = _continent;
  }
  
  void setColor(int i){
    float h = 0;
    float s = 0;
    float b = 0;
    if(continent.equals("Europa")){
      h = 230;
      s = 50;
      b = 100;  
      h += i * 5;  
    }else if(continent.equals("África")){
      h = 28;
      s = 60;
      b = 100;   
      h -= i * 7;         
    }else if(continent.equals("Ásia")){
      h = 50;
      s = 100;
      b = 100;  
      h -= i * 2;
    }else if(continent.equals("América do Norte, Central e Caribe")){
      h = 180;
      s = 100;
      b = 90;
      h += i * 5;
    }else if(continent.equals("América do Sul")){
      h = 90;
      s = 70;
      b = 80;
       h += i * 15; 
    }else{
      h = 90;
      s = 0;
      b = 80;    
    }
  
    myColor = color(h, s, b);  
  }
}
