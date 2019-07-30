import controlP5.*;
import http.requests.*;
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
  cp5.addBang("post_request")
     .setPosition(100+10,100)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;    
  textFont(font);
}
void draw(){
  background(0);
  fill(255);
  text("transmit data:", 10, 20);
  text("Post data:", 10, 80);
}
public void post_request() {
  //http post
  String api_url = url + "?" + keys[0] + "=" + cp5.get(Textfield.class,keys[0]).getText();
  for(int i=1;i<keys.length;i++)
    api_url += "&" + keys[i] + "=" + cp5.get(Textfield.class,keys[i]).getText();
  PostRequest post = new PostRequest(api_url);
  post.addHeader("Content-Type", "application/json");
  post.send();
  println("Reponse Content: " + post.getContent());
  System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
  
  uuid = cp5.get(Textfield.class,keys[0]).getText();
  longitude = cp5.get(Textfield.class,keys[1]).getText();
  latitude = cp5.get(Textfield.class,keys[2]).getText();
  compass = cp5.get(Textfield.class,keys[3]).getText();
  message = cp5.get(Textfield.class,keys[4]).getText();
  text(uuid, 100+10,80);
  text(longitude, 100+10*2+100*1,80);
  text(latitude, 100+10*3+100*2,80);
  text(compass, 100+10*4+100*3,80);
  text(message, 100+10*5+100*4,80);
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
