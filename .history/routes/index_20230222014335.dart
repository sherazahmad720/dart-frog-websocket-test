import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

class ChatRoom {
  final List<WebSocketChannel> _clients = [];

  void handleWebSocket(WebSocketChannel channel, String? protocol) {
    _clients.add(channel);

    channel.sink.add('Welcome to the chat room!');

    channel.stream.listen((message) {
      for (var client in _clients) {
        client.sink.add('User: $message');
      }
    }, onDone: () {
      _clients.remove(channel);
    });
  }
}

Future<Response> chatRoomHandler(RequestContext context) async {
  final chatRoom = ChatRoom();
  final handler = webSocketHandler(chatRoom.handleWebSocket);

  return handler(context);
}
