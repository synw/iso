import 'dart:io';

import 'package:iso/iso.dart';
import 'package:pedantic/pedantic.dart';

Future<void> runServer(IsoRunner iso) async {
  final server = await HttpServer.bind("localhost", 8080);
  iso.send("Server started: try curl http://localhost:8080 to make a request");
  await for (final request in server) {
    // inform the main thread
    iso.send("Request: ${request.uri.path}");
    // send a response to the request
    request.response.write("ok");
    await request.response.close();
  }
}

Future<void> main() async {
  /// The [onDataOut] parameter is ommited so by default the data coming
  /// from the isolate will print to the screen
  unawaited(Iso(runServer, onDataOut: print).run());
}
