import 'package:iso/iso.dart';
import 'package:pedantic/pedantic.dart';

Future<void> run(IsoRunner iso) async {
  iso.send('Running');
  throw Exception("An error has occured");
}

void onError(dynamic err) {
  print("*** Error in the isolate:");
  throw err;
}

Future<void> main() async {
  unawaited(Iso(run, onError: onError).run());
}
