import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:iso/iso.dart';

void onDataOut(dynamic data) {
  print("Data from isolate -> $data / ${data.runtimeType}");
}

void onDataIn(dynamic data) =>
    print("Data received in isolate -> $data / ${data.runtimeType}");

void run(SendPort chan) async {
  Iso.onDataIn(chan, onDataIn);
  chan.send("Message 1");
  await Future<dynamic>.delayed(Duration(seconds: 1));
  chan.send(["Message 2"]);
  await Future<dynamic>.delayed(Duration(seconds: 3));
  chan.send([1, 2, 3]);
  await Future<dynamic>.delayed(Duration(seconds: 5));
  chan.send("Message 4");
  await Future<dynamic>.delayed(Duration(seconds: 1));
  chan.send("finished");
  //print("Making an error:");
  //throw ("ERROR MESSAGE");
}

void main() async {
  print("Creating runner");
  var iso = Iso(run, onDataOut: onDataOut);
  print("Running isolate");
  iso.run();
  await iso.onReady;
  iso.dataOut.listen((dynamic payload) {
    if (payload == "finished") {
      print("Isolate declares it has finished");
      iso.kill();
      exit(0);
    }
  });
  await Future<dynamic>.delayed(Duration(seconds: 3));
  print("Sending data");
  iso.send([1, 2, 3]);
  await Future<dynamic>.delayed(Duration(seconds: 1));
  iso.send({"one": 1});
}
