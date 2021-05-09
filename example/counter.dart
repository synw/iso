import 'dart:async';

import 'package:iso/iso.dart';
import 'package:pedantic/pedantic.dart';

Future<void> run(IsoRunner iso) async {
  var counter = 0;
  iso.receive();
  iso.dataIn!.listen((dynamic data) {
    counter = counter + int.parse(data.toString());
    // send into the main thread
    iso.send(counter);
  });
}

Future<void> main() async {
  final iso = Iso(run, onDataOut: (dynamic data) => print("Counter: $data"));
  unawaited(iso.run());
  await iso.onCanReceive;
  Timer.periodic(const Duration(seconds: 1), (_) => iso.send(1));
}
