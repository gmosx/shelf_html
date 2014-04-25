library shelf_html;

import 'dart:html';
import 'dart:async';

import 'package:shelf/shelf.dart';

/**
 * The local (i.e. client-side) instance of Shelf.
 */
class Local { // TODO: find a better name.
  dynamic _handler;

  Local(this._handler);

  void get(String path, {Map state: const {}, String title: ''}) {
    window.history.pushState(state, title, path);
    _onWindowLocationChange();
  }

  void _onWindowLocationChange() {
    final request = new Request('GET', new Uri(scheme: 'http', path: window.location.pathname));
    _handler(request).then((Response response) {
      switch (response.statusCode) {
        // If the statusCode of the  response is 30x perform an 'internal redirect'
        // by changing the window location.
        case 303:
        case 302:
        case 301:
          get(response.headers['location']);
          break;
      }
    });
  }
}

/**
 * Implements the dart:html Shelf adapter.
 */
Future<Local> serve(handler) {
  final local = new Local(handler);

  window.onPopState.listen((PopStateEvent e) {
    local._onWindowLocationChange();
  });

  // Handle the initial window location.
  local._onWindowLocationChange();

  return new Future.value(local);
}