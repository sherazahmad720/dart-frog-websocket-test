import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

final clients = <WebSocketChannel>{};

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      clients.add(channel);
      print('connected');

      // Send a message to the client.
      channel.sink.add('hello from the server');

      // Listen for messages from the client.
      channel.stream.listen(
        // The client has sent a message.
        (message) => {
          print('received: $message'),

          // Broadcast the message to all clients.
          for (final client in clients)
            {client.sink.add('Client said: $message')},
        },

        // The client has disconnected.
        onDone: () => {
          clients.remove(channel),
          print('disconnected'),
        },
      );
    },
  );

  return handler(context);
}
