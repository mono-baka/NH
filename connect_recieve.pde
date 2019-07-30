import controlP5.*;
ControlP5 cp5;
String url = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
String[] keys = {"uuid", "longitude", "latitude", "compass", "message"};
String uuid="", longitude="", latitude="", compass="", message="";
void setup(){
  size(700, 400);
  //user interface
  PFont font = createFont("arial",12);
  cp5 = new ControlP5(this);
  for(int i=0;i<keys.length;i++){
    cp5.addTextfield(keys[i])
       .setPosition(100+10*(i+1)+100*i, 10)
       .setSize(100,20)
       .setFont(font)
       .setFocus(true)
       .setColor(255)//color(255,0,0))
       ;
  }
  cp5.addBang("get_request")
     .setPosition(100+10,100)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;    
  textFont(font);
}
void draw(){
  background(0);
  fill(255);
  text(uuid, 100+10,80);
  text(longitude, 100+10*2+100*1,80);
  text(latitude, 100+10*3+100*2,80);
  text(compass, 100+10*4+100*3,80);
  text(message, 100+10*5+100*4,80);
  text("URL query:", 10, 20);
  text("Get data:", 10, 80);
}
public void get_request() {
  String api_url = url + "?" + keys[0] + "=" + cp5.get(Textfield.class,keys[0]).getText();
  for(int i=1;i<keys.length;i++)
    api_url += "&" + keys[i] + "=" + cp5.get(Textfield.class,keys[i]).getText();
  println(api_url);
  JSONArray d_array = loadJSONArray(api_url);
  JSONObject d = d_array.getJSONObject(0);
  println(d);
  uuid = d.getString(keys[0]);
  longitude = d.getString(keys[1]);
  latitude = d.getString(keys[2]);
  compass = d.getString(keys[3]);
  message = d.getString(keys[4]);
  cp5.get(Textfield.class,"uuid").clear();
  cp5.get(Textfield.class,"longitude").clear();
  cp5.get(Textfield.class,"latitude").clear();
  cp5.get(Textfield.class,"compass").clear();
  cp5.get(Textfield.class,"message").clear();
}
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
}
public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}
