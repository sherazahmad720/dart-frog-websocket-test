import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  // A set to keep track of all connected clients
  final clients = <WebSocketChannel>{};

  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      print('connected');

      // Add the client to the set of connected clients
      clients.add(channel);

      // Send a message to the client.
      channel.sink.add('hello from the server');

      // Listen for messages from the client.
      channel.stream.listen(
        // The client has sent a message.
        (message) {
          print('received: $message');

          // Send the message to all connected clients
          clients.forEach((client) {
            if (client != channel) client.sink.add('received: $message');
          });
        },

        // The client has disconnected.
        onDone: () {
          print('disconnected');

          // Remove the client from the set of connected clients
          clients.remove(channel);
        },
      );
    },
  );

  return handler(context);
}
