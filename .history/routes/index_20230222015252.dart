import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

final clients = <WebSocketChannel>{};

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // Prompt the user to enter their name.
      channel.sink.add('Please enter your name:');
      String name = '';

      // Listen for messages from the client.
      channel.stream.listen(
        // The client has sent a message.
        (message) {
          if (name.isEmpty) {
            // Save the user's name.
            name = message.toString();
            clients.add(channel);
            print('User connected: $name');
          } else {
            print('$name said: $message');

            // Broadcast the message to all clients.
            for (final client in clients) {
              client.sink.add('$name: $message');
            }
          }
        },

        // The client has disconnected.
        onDone: () => {
          clients.remove(channel),
          print('User disconnected: $name'),
        },
      );
    },
  );

  return handler(context);
}
