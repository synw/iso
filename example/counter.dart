import 'package:iso/iso.dart';

void run(IsoRunner iso) async {
  int counter = 0;
  iso.receive();
  iso.dataIn.listen((dynamic data) {
    counter = counter + int.parse(data.toString());
    // send into the main thread
    iso.send(counter);
  });
}

void main() async {
  final iso = Iso(run, onDataOut: (dynamic data) => print("Counter: $data"));
  iso.run();
  await iso.onCanReceive;
  while (true) {
    await Future<dynamic>.delayed(Duration(seconds: 1));
    iso.send(1);
  }
}
