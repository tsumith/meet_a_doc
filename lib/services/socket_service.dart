import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketHelper {
  final String url;
  late IOWebSocketChannel _channel;

  WebSocketHelper({required this.url});

  // Connect to the WebSocket server
  void connect() {
    try{
       print("connection is successful");
    _channel = IOWebSocketChannel.connect(url);
    }catch(e){
      print("connection failed");
    }
   
  }

  // Send a message to the server
  void sendMessage(String message) {
    if (_channel.sink != null) {
      _channel.sink.add(message);
    }
  }

  // Listen to incoming messages
  Stream<dynamic> get messages => _channel.stream;

  // Close the WebSocket connection
  void close() {
    _channel.sink.close();
  }
}