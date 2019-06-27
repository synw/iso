# Iso

An isolates runner that handles bidirectionnal communication.

Run some code in an isolate and communicate with it:

   ```dart
   import 'dart:isolate';
   import 'package:iso/iso.dart';

   void run(SendPort chan) async {
     int counter = 0;
     // listen for the data coming in
     Iso.onDataIn(chan, (dynamic data) {
       counter = counter + int.parse(data.toString());
       // send into the main thread
       chan.send(counter);
     });
   }

   void main() async {
     final iso = Iso(run, onDataOut: (dynamic data) => print("Counter: $data"));
     iso.run();
     await iso.onReady;
     while (true) {
       await Future<dynamic>.delayed(Duration(seconds: 1));
       // send data to the isolate
       iso.send(1);
     }
     // terminate the isolate:
     iso.kill()
   }
   ```
