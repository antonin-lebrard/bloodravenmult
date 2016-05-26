import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'package:json_object/json_object.dart';

WebSocket ws = new WebSocket("ws://localhost:40000");

TextInputElement input = querySelector('#input');
ParagraphElement output = querySelector('#output');

List<String> usernames = ["sdfsd", "sdfjfdjbdgdg", "dfudg", "dfjdfud", "sdf0", "sdf", "hfjfk", "dfg"];

Random rand = new Random();

int ran = rand.nextInt(usernames.length);

Map connect = {
  "method": "connect",
  "params": {
    "username": usernames[ran]
  }
};

Map send = {
  "method": "messageToAll",
  "params": {
    "username": usernames[ran],
    "message": null
  }
};

void main(){
  ws.onOpen.listen((Event e) {
    outputMessage('Connected to server');
    ws.send(JSON.encode(connect));
  });

  ws.onMessage.listen((MessageEvent e){
    outputMessage(new JsonObject.fromJsonString(e.data).message);
  });

  ws.onClose.listen((Event e) {
    outputMessage('Connection to server lost...');
  });

  input.onChange.listen((Event e){
    wsSend(input.value.trim());
    input.value = "";
  });

}

void wsSend(String message){
  send["params"]["message"] = message;
  ws.send(JSON.encode(send));
}

void outputMessage(String message){
  print(message);
  output.appendText(message);
  output.appendHtml('<br/>');

  //Make sure we 'autoscroll' the new messages
  output.scrollTop = output.scrollHeight;
}
