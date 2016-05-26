library bloodravenmult.user;

import 'dart:io';

import "package:json_object/json_object.dart";

class UserPool {

  static Map<String, IOUser> users = new Map();

  static registerUser(User user, WebSocket socket){
    IOUser u = new IOUser(user, socket);
    users[u.data.username] = u;
  }

  static unRegisterUser(WebSocket socket){
    String username = "";
    List<IOUser> u = users.values.toList();
    for (int i = 0; i < users.length; i++) {
      if (u[i].socket == socket){
        username = users.keys.toList()[i];
        break;
      }
    }
    users.remove(username);
  }

}

class IOUser {

  User data;
  WebSocket socket;

  IOUser(this.data, this.socket);

}

/// Definition of [User] for [JsonObject]
abstract class User {
  String username;
  String roomname;
  String charname;
}

/// Implement [JsonObject] for rapid toJson/fromJson conversion
class UserImpl extends JsonObject implements User{
  UserImpl();
  UserImpl.fromJsonObject(JsonObject obj){
    this.username = obj.username;
    this.roomname = obj.roomname;
    this.charname = obj.charname;
  }
  factory UserImpl.fromJsonString(String string){
    return new JsonObject.fromJsonString(string);
  }
}