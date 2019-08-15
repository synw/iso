# Iso

[![pub package](https://img.shields.io/pub/v/iso.svg)](https://pub.dartlang.org/packages/iso)

An isolates runner that handles bidirectionnal communication. Run some code in an isolate and communicate with it.

## Example

   ```dart
   import 'package:iso/iso.dart';

   void run(IsoRunner iso) async {
     int counter = 0;
     // init the data in channel
     iso.receive();
     // listen to the data coming in
     iso.dataIn.listen((dynamic data) {
       counter = counter + int.parse("$data");
       // send into the main thread
       iso.send(counter);
     });
   }

   void main() async {
     final iso = Iso(run, onDataOut: (dynamic data) => print("Counter: $data"));
     iso.run();
     await iso.onCanReceive;
     // now we can send messages to the isolate
     while (true) {
       await Future<dynamic>.delayed(Duration(seconds: 1));
       iso.send(1);
     }
   }
   ```

## Usage

### Initialize

Define a function to be run in an isolate:

   ```dart
   void run(IsoRunner iso) {
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
   iso.run();
   // to terminate it:
   iso.dispose();
   ```

The function can be run with parameters:

   ```dart
   final params = <dynamic>["arg1", "arg2", 3];
   iso.run(params);
   ```

To grab the parameters in the isolate:

   ```dart
   void run(IsoRunner iso) {
      if (iso.hasArgs) {
        final List<dynamic> args = iso.args;
      }
   }
   ```

### Communication channels

#### Data coming from the isolate

Handle data coming from the isolate using a handler function:

   ```dart
   void onDataOut(dynamic data) => print("Data coming from isolate: $data");

   final iso = Iso(run, onDataOut: onDataOut);
   ```

If `onDataOut`is not provided it will print the data to the terminal by default. To disable the default behavior set `onDataOut` to null:

   ```dart
   final iso = Iso(run, onDataOut: null)
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

By default this data channel is not activated: you need to do it in the run function if needed:

   ```dart
   void run(IsoRunner iso) {
     iso.receive();
     iso.dataIn.listen((dynamic data) {
       // do something with the data
     });
   }
   ```

or:

   ```dart
   void run(IsoRunner iso) {
     iso.receive()
       ..listen((dynamic data) =>
         print("Data received in isolate -> $data / ${data.runtimeType}"));
   }
   ```

#### Send data to the isolate

This has to be initialized in the isolate before sending as explained above.

   ```dart
   iso.run();
   // wait for the isolate to be ready to receive data
   await iso.onCanReceive;
   // send data
   iso.send("Some data");
   ```  

#### Send data from the isolate to the main thread

   ```dart
   void run(IsoRunner iso) {
      // ...
      iso.send("Some data");
   }
   ```

## Examples

Check the [example](https://github.com/synw/iso/tree/master/example) folder to see examples for Dart and Flutter
