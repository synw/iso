# Iso

[![pub package](https://img.shields.io/pub/v/iso.svg)](https://pub.dartlang.org/packages/iso)

An isolates runner that handles bidirectionnal communication.

Run some code in an isolate and communicate with it:

## Example

   ```dart
   import 'dart:isolate';
   import 'package:iso/iso.dart';

   void run(SendPort chan) {
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

## Usage

### Initialize

Define a function to be run in an isolate:

   ```dart
   void run(SendPort chan) {
      // do something here
   }
   ```

**Important**: this must be a top level function or a static method. The
function can be async if needed

Initialize a runner:

   ```dart
   final iso = Iso(run);
   ```

Launch the function in the isolate:

   ```dart
   iso.run()
   // if you wwant to send data into the isolate you need to
   // wait until it is ready
   await iso.onReady;
   // to terminate it:
   iso.kill()
   ```

### Communication channels

#### Data coming from the isolate

Handle data coming from the isolate using a handler function:

   ```dart
   void onDataOut(dynamic data) => print("Data coming from isolate: $data");

   final iso = Iso(run,onDataOut: onDataOut);
   ```

Another option to handle this data is to listen to a channel:

   ```dart
   iso.dataOut.listen((dynamic payload) {
     if (payload == <String, dynamic>{"status": "finished"}) {
       print("Isolate declares it has finished");
       iso.kill();
     }
   });
   ```

#### Data coming into the isolate

Handle data coming into the isolate using a handler function:

   ```dart
   void onDataIn(dynamic data) => print("Data coming in: $data");

   void run(SendPort chan) {
      Iso.onDataIn(chan, onDataIn);
      // ...
   }
   ```

Another option to handle this data is to listen to a channel:

   ```dart
   void run(SendPort chan) {
      final ReceivePort dataInChan = Iso.dataInChan(chan);
      dataInChan.listen((dynamic data) {
        print("Data coming in: $data");
      });
      // ...
   }
   ```

#### Send data to the isolate

   ```dart
   iso.send("Some data");
   ```  

#### Send data from the isolate to the main thread

   ```dart
   void run(SendPort chan) {
      // ...
      chan.send("Some data");
   }
   ```
