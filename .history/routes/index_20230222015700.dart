import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

final List<WebSocketChannel> _clients = [];

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      print('connected');
      _clients.add(channel);

      // Send a welcome message to the new client.
      channel.sink.add('Welcome to the chat room! Please enter your username.');

      // Listen for messages from the client.
      String? username;
      channel.stream.listen(
        (message) {
          if (username == null) {
            // The first message is the user's username.
            username = message.toString();
            // Notify all clients that a new user has joined the chat room.
            _broadcastMessage('$username has joined the chat room.');
          } else {
            // The client has sent a message.
            print('$username: $message');
            // Send the message to all other clients.
            _broadcastMessage('$username: $message', exclude: channel);
          }
        },
        // The client has disconnected.
        onDone: () {
          _clients.remove(channel);
          if (username != null) {
            // Notify all clients that the user has left the chat room.
            _broadcastMessage('$username has left the chat room.');
          }
          print('disconnected');
        },
      );
    },
  );

  return handler(context);
}

void _broadcastMessage(String message, {WebSocketChannel? exclude}) {
  for (final client in _clients) {
    if (client != exclude) {
      client.sink.add(message);
    }
  }
}
