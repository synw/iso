import "dart:math";
import 'dart:async';
import 'package:iso/iso.dart';

final _random = Random();

class CustomPayload {
  CustomPayload({this.number, this.name, this.data});

  final int number;
  final String name;
  final Map<String, dynamic> data;

  @override
  String toString() => "$number $name $data";
}

void run(IsoRunner iso) async {
  iso.receive()
    ..listen((dynamic data) {
      if (data is int)
        print("Received integer: $data");
      else if (data is String)
        print("Received string: $data");
      else if (data is CustomPayload)
        print("Reveived custom payload: $data");
      else
        print("Unknown data type: $data");
    });
  // send messages
  int i = 0;
  while (true) {
    await Future<dynamic>.delayed(Duration(seconds: _random.nextInt(1 << 2)));
    sendMessage(iso, i);
    i++;
  }
}

void main() async {
  final iso = Iso(run, onDataOut: null)..run();
  // listen
  iso.dataOut.listen((dynamic data) => print(" -> From iso : $data"));
  // get ready
  await iso.onCanReceive;
  // send messages
  int i = 0;
  while (true) {
    await Future<dynamic>.delayed(Duration(seconds: _random.nextInt(1 << 2)));
    sendMessage(iso, i);
    i++;
  }
}

enum MessageType { integer, string, custom }

void sendMessage(dynamic iso, int i) {
  final choices = <MessageType>[
    MessageType.integer,
    MessageType.string,
    MessageType.custom
  ];
  final choice = choices[_random.nextInt(choices.length)];
  switch (choice) {
    case MessageType.integer:
      iso.send(i);
      break;
    case MessageType.string:
      iso.send("A string $i");
      break;
    case MessageType.custom:
      final payload = CustomPayload(
          number: i, name: "Payload $i", data: <String, dynamic>{"k": "v"});
      iso.send(payload);
  }
}
