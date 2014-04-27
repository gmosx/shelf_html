library shelf_html;

import 'dart:html';
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/src/util.dart';
import 'package:stack_trace/stack_trace.dart';

/**
 * The local (i.e. client-side) instance of Shelf.
 */
class Local { // TODO: find a better name.
  dynamic _handler;

  Local(this._handler) {
    catchTopLevelErrors(() {
      window.onPopState.listen(_onWindowLocationChange);

      // Handle the initial window location.
      _onWindowLocationChange();
    }, (error, stackTrace) {
      _logError("Asynchronous error\n$error", stackTrace);
    });
  }

  /**
   * Go (i.e. route) to the specified (internal) [path].
   *
   * Quite inexplicably, the History API does not provide an [onPush] event
   * (that I know of). This method to forces a call to the
   * [_onWindowLocationChange] event handler.
   */
  void go(String path, {Map state: const {}, String title: ''}) {
    window.history.pushState(state, title, path);
    _onWindowLocationChange();
  }

  /**
   * Alias to be consistent with the HTTP oriented Shelf API.
   */
  void get(String path) => go(path);

  void _onWindowLocationChange([PopStateEvent e]) {
    final request = new Request('GET', new Uri(scheme: 'http', path: window.location.pathname));
    syncFuture(() => _handler(request)).then((Response response) {
      if (response == null) {
        response = _logError("Null response from handler");
      }
      switch (response.statusCode) {
        // If the statusCode of the  response is 30x perform an 'internal redirect'
        // by changing the window location.
        case 303:
        case 302:
        case 301:
          go(response.headers['location']);
          break;
      }
    });
  }

  Response _logError(String message, [StackTrace stackTrace]) {
    var chain = new Chain.current();
    if (stackTrace != null) {
      chain = new Chain.forTrace(stackTrace);
    }
    chain = chain
        .foldFrames((frame) => frame.isCore || frame.package == 'shelf')
        .terse;

    print('ERROR - ${new DateTime.now()}');
    print(message);
    print(chain);
    return new Response.internalServerError();
  }
}

/**
 * Implements the dart:html Shelf adapter.
 */
Future<Local> serve(handler) {
  return new Future.value(new Local(handler));
}