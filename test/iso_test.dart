import 'dart:async';
import 'package:pedantic/pedantic.dart';
import "package:test/test.dart";
import 'package:iso/iso.dart';

void run(IsoRunner iso) {
  var counter = 0;
  // listen for the data coming in
  iso.receive();
  iso.dataIn!.listen((dynamic data) {
    counter = counter + int.parse(data.toString());
    // send into the main thread
    iso.send(counter);
  });
}

void main() {
  Iso? iso;

  final valueLog = StreamController<int?>();

  test("constructor", () {
    iso = Iso(run, onDataOut: (dynamic data) => print("Counter: $data"));
    expect(iso is Iso, true);
    expect(iso == null, false);
    return;
  });

  test("listen logs", () {
    iso!.dataOut.listen((dynamic data) {
      valueLog.sink.add(data as int?);
    });
    return;
  });

  test("run", () async {
    unawaited(iso!.run());
    await iso!.onCanReceive;
    expect(iso!.canReceive, true);
    return;
  });

  test("send", () async {
    assert(iso!.canReceive);
    iso!.send(1);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    iso!.send(1);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    var i = 1;
    valueLog.stream.listen((int? v) {
      expect(v, i);
      i++;
      if (i > 2) {
        valueLog.close();
        return;
      }
    });
  });
}
