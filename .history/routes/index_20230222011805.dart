import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      print('connected');

      // Send a message to the client.
      channel.sink.add('hello from the server');

      // Listen for messages from the client.
      channel.stream.listen(
        // The client has sent a message.
        (message) => {
          print('received: $message'),
          channel.sink.add('hello from the server\n you send $message'),
          //send message to all
          channel.sink.addStream(channel.stream),
        },

        // The client has disconnected.
        onDone: () => print('disconnected'),
      );
    },
  );

  return handler(context);
}
