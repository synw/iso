import 'package:iso/iso.dart';

void run(IsoRunner iso) async {
  iso.send('Running');
  throw ("An error has occured");
}

void onError(dynamic err) {
  print("*** Error in the isolate:");
  throw (err);
}

void main() async {
  Iso(run, onError: onError)..run();
}
