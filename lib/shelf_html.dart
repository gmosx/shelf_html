library shelf_html;

import 'dart:html';
import 'dart:async';

import 'package:shelf/shelf.dart';

// TODO: find a better name.
class Server {
  dynamic _handler;

  Server(this._handler);

  void get(String path, {Map state: const {}, String title: ''}) {
    window.history.pushState(state, title, path);
    process();
  }

  // TODO: find a better name.
  void process() {
    final request = new Request('GET', new Uri(
      scheme: 'http',
      path: window.location.pathname));
    _handler(request).then((Response response) {
      switch (response.statusCode) {
        // TODO: maybe use other 30x status?
        case 303:
          get(response.headers['location']);
          break;
      }
    });
  }
}

/**
 *
 */
Future<Server> serve(handler) {
  final server = new Server(handler);
  window.onPopState.listen((PopStateEvent e) {
    server.process();
  });
  // Process the initial url.
  server.process();
  return new Future.value(server);
}