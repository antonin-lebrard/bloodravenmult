import 'dart:io';
import 'dart:convert';
import 'package:bloodravenmult/user.dart';
import "package:bloodravenmult/method.dart";
import "package:json_object/json_object.dart";

void main(){

  int port = 40000;

  HttpServer.bind(InternetAddress.ANY_IP_V4, port)
      .then((HttpServer server) {
    print('listening for connections on $port');

    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((WebSocket websocket){
        WebSocketPool.addWebSocket(websocket);
      });
    });
  }, onError: (error) => print("Error starting HTTP server: $error"));

}

class WebSocketPool {

  static void addWebSocket(WebSocket websocket){
    websocket.done.then((_){
      print("websocket closed");
      UserPool.unRegisterUser(websocket);
    });
    websocket.listen((data){
      print(UserPool.users);
      websocket.add(JSON.encode(verifyFormat(data, websocket, pointsToMethods)));
    }, onError: (err){
      print(err);
      UserPool.unRegisterUser(websocket);
    }, onDone: (){
      print("websocket closed");
      UserPool.unRegisterUser(websocket);
    });
  }

  static JsonObject verifyFormat(String data, WebSocket socket, Function callback){
    print("received : $data");
    bool error = false;
    if (data == null || data.length == 0) error = true;
    if (!error) {
      try {
        JsonObject obj = new JsonObject.fromJsonString(data);
        if (!obj.containsKey('method') || !obj.containsKey('params') || !obj.params.containsKey('username')) error = true;
        if (!error) return callback(obj, socket);
      } catch(e){
        print(e);
      }
    }
    print('{"error":"wrong format, expect {\'method\': nameofmethod, \'params\': { something }}"}');
    return new JsonObject.fromJsonString('{"error":"wrong format, expect {\'method\': nameofmethod, \'params\': { something }}"}');
  }

  static JsonObject pointsToMethods(JsonObject data, WebSocket socket){
    for (Method method in Method.allMethods){
      if (method.name == data.method){
        JsonObject response = method.run(data.params, socket);
        print("responded : $response");
        return response;
      }
    }
    print('{"error" : "method : ${data.method} not existing"}');
    return new JsonObject.fromJsonString('{"error" : "method : ${data.method} not existing"}');
  }

}