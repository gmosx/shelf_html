library shelf_html;

import 'dart:html';

import 'package:shelf/shelf.dart';
import 'package:shelf/src/util.dart';
import 'package:stack_trace/stack_trace.dart';

// TODO: add fine-grained logging.

/**
 * The local (i.e. client-side) instance of Shelf.
 */
class Local { // TODO: find a better name.
  dynamic _handler;

  /** A prefix prepended to all 'local' paths. */
  String basePath;

  Local(this._handler, {this.basePath: ''}) {
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
  void go(String path, {Map state, String title: ''}) {
    // TODO: use const map when dart2js bug is fixed (issue #1).
    if (state == null) state = {};
    window.history.pushState(state, title, '$basePath$path');
    _onWindowLocationChange();
  }

  /**
   * Alias to be consistent with the HTTP oriented Shelf API.
   */
  void get(String path) => go(path);

  void _onWindowLocationChange([PopStateEvent e]) {
    // Normalize the path by removing the [basePath] prefix.
    final path = window.location.pathname.replaceFirst(new RegExp('^$basePath'), '');

    final request = new Request('GET', new Uri(scheme: 'http', path: path));

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

    // TODO: use the logging framework.
    print('ERROR - ${new DateTime.now()}');
    print(message);
    print(chain);
    return new Response.internalServerError();
  }
}

/**
 * Implements the dart:html Shelf adapter entry-point.
 */
Local serve(handler, {String basePath}) {
  return new Local(handler, basePath: basePath);
}