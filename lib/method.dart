library bloodravenmult.method;

import 'dart:io';

import "package:json_object/json_object.dart";
import "package:bloodravenmult/user.dart";
import 'dart:convert';

abstract class Method {
  static JsonObject _SUCCESS_MESS = new JsonObject.fromJsonString('{"success" : "success"}');
  static List<Method> allMethods = [new Connect(), new MessageToAll(), new MessageToRoom()];

  static JsonObject _error(String error){
    return new JsonObject.fromJsonString('{"error" : "$error"}');
  }

  JsonObject run(JsonObject params, WebSocket socket);
  String get name;
}

class Connect extends Method {
  String get name => "connect";
  JsonObject run(JsonObject params, WebSocket socket) {
    if (UserPool.users.containsKey(params.username)){
      return Method._error("user already connected");
    }
    UserPool.registerUser(new UserImpl.fromJsonObject(params), socket);
    return Method._SUCCESS_MESS;
  }
}

abstract class ConnectedMethod extends Method {
  JsonObject run(JsonObject params, WebSocket socket) {
    if (UserPool.users[params.username] == null){
      return Method._error("user not connected");
    }
    updateUser(params);
    return _run(params);
  }
  JsonObject _run(JsonObject params);
  void updateUser(JsonObject params){
    IOUser user = UserPool.users[params.username];
    user.data = new UserImpl.fromJsonObject(params);
  }
}

class MessageToAll extends ConnectedMethod {
  String get name => "messageToAll";
  JsonObject _run(JsonObject params) {
    if (!params.containsKey('message')){
      return Method._error("no message key in params");
    }
    String mess = JSON.encode({
      "message":params.message,
      "from": params.containsKey("charname") ? params.charname : params.username,
      "context":"all"
    });
    for (IOUser user in UserPool.users.values){
      user.socket.add(mess);
    }
    return Method._SUCCESS_MESS;
  }
}

class MessageToRoom extends ConnectedMethod {
  String get name => "messageToRoom";
  JsonObject _run(JsonObject params) {
    if (!params.containsKey('message') || !params.containsKey('roomname')){
      return Method._error("no message key or roomane key in params");
    }
    String mess = JSON.encode({
      "message":params.message,
      "from": params.containsKey("charname") ? params.charname : params.username,
      "context":"room"
    });
    for (IOUser user in UserPool.users.values){
      print(user.data.roomname);
      if (user.data.roomname == params.roomname){
        user.socket.add(mess);
      }
    }
    return Method._SUCCESS_MESS;
  }
}