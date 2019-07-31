import 'dart:async';
import 'dart:io';
import 'package:iso/iso.dart';

void run(IsoRunner iso) async {
  if (iso.hasArgs) print("Arguments: ${iso.args}");
  /*iso.onCanReceive.then((dynamic _) {
    print("iso can receive");
    iso.dataIn.listen((dynamic data) =>
        print("Data received in isolate -> $data / ${data.runtimeType}"));
  });*/
  /*iso.initDataIn();
  iso.dataIn.listen((dynamic data) {
    print("Data received in isolate -> $data / ${data.runtimeType}");
  });*/
  iso.receive()
    ..listen((dynamic data) =>
        print("Data received in isolate -> $data / ${data.runtimeType}"));
  iso.send("Message 1");
  await Future<dynamic>.delayed(Duration(seconds: 1));
  iso.send(["Message 2"]);
  await Future<dynamic>.delayed(Duration(seconds: 3));
  iso.send([1, 2, 3]);
  await Future<dynamic>.delayed(Duration(seconds: 5));
  iso.send("Message 4");
  await Future<dynamic>.delayed(Duration(seconds: 1));
  iso.send("finished");
}

void main() async {
  print("Creating runner");

  /// disable the [onDataOut] callback and use the [iso.dataOut] listener
  final iso = Iso(run, onDataOut: null);
  // listen to the data coming from the isolate
  iso.dataOut.listen((dynamic payload) {
    if (payload == "finished") {
      print("Isolate declares it has finished");
      iso.dispose();
      exit(0);
    } else {
      print("Data from isolate -> $payload / ${payload.runtimeType}");
    }
  });
  print("Running isolate");
  iso.run(<dynamic>["arg1", "arg2"]);
  // wait for the isolate to be ready to receive data
  await iso.onCanReceive;

  await Future<dynamic>.delayed(Duration(seconds: 3));
  print("Sending data");
  iso.send([1, 2, 3]);
  await Future<dynamic>.delayed(Duration(seconds: 1));
  iso.send({"one": 1});
}
