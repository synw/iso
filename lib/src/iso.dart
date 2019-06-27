import "dart:isolate";
import 'dart:async';

/// The isolate runner class
class Iso {
  /// If [onDataOut] is not provided the data coming from the isolate
  /// will print to the screen by default
  Iso(this.runFunction, {this.onDataOut = print})
      : _receivePort = ReceivePort(),
        _errorPort = ReceivePort() {
    onError ??= (dynamic err) => throw ("Error in isolate:\n $err");
  }

  /// The function to run in the isolate
  final void Function(SendPort port) runFunction;

  /// The handler for the data coming from the isolate
  Function onDataOut;

  /// The handler for the errors coming from the isolate
  Function onError;

  Isolate _isolate;
  ReceivePort _receivePort;
  ReceivePort _errorPort;
  SendPort _isolateSendPort;
  final StreamController<dynamic> _dataOutIsolate = StreamController<dynamic>();
  final Completer _readyCompleter = Completer<void>();

  /// A stream with the data coming out from the isolate
  Stream<dynamic> get dataOut => _dataOutIsolate.stream;

  /// Working state callback
  Future get onReady => _readyCompleter.future;

  /// Handler for the data received inside the isolate
  static ReceivePort onDataIn(SendPort chan, Function handler) {
    final listener = ReceivePort();
    chan.send(listener.sendPort);
    listener.listen((dynamic data) {
      handler(data);
    });
    return listener;
  }

  /// Channel to listen for data coming in the isolate
  static ReceivePort dataInChan(SendPort chan) {
    final listener = ReceivePort();
    chan.send(listener.sendPort);
    return listener;
  }

  /// Send data to the isolate
  void send(dynamic data) {
    assert(_isolateSendPort != null);
    _isolateSendPort.send(data);
  }

  /// Run the isolate
  Future<void> run() async {
    _receivePort = ReceivePort();
    _errorPort = ReceivePort();
    final Completer _comChanCompleter = Completer<void>();
    _isolate = await Isolate.spawn(runFunction, _receivePort.sendPort,
            onError: _errorPort.sendPort)
        .then((Isolate _) {
      _receivePort.listen((dynamic data) {
        if (_isolateSendPort == null && data is SendPort) {
          _isolateSendPort = data;
          _comChanCompleter.complete();
        } else {
          _dataOutIsolate.sink.add(data);
          onDataOut(data);
        }
      }, onError: (dynamic err) {
        _errorPort.sendPort.send(err);
      });
      _errorPort.listen((dynamic err) {
        onError(err);
      });
      return;
    });
    await _comChanCompleter.future;
    _readyCompleter.complete();
  }

  /// Kill the isolate
  void kill() {
    if (_isolate != null) {
      _receivePort.close();
      _errorPort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  /// Cleanup
  void dispose() {
    kill();
    _dataOutIsolate.close();
  }
}
