import 'dart:io';
import 'dart:isolate';
import 'package:iso/iso.dart';

void runServer(SendPort chan) async {
  final server = await HttpServer.bind("localhost", 8080);
  chan.send("Server started: try curl http://localhost:8080 to make a request");
  await for (final request in server) {
    // inform the main thread
    chan.send("Request: ${request.uri.path}");
    // send a response to the request
    request.response.write("ok");
    request.response.close();
  }
}

void main() {
  /// The [onDataOut] parameter is ommited so by default the data coming
  /// from the isolate will print to the screen
  Iso(runServer)..run();
}
