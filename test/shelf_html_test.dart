import 'dart:html';
import 'dart:async';

import 'package:unittest/unittest.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf_html/shelf_html.dart' as shelf_html;

Response _redirectHandler(Request request) {
  if (request.url.path != '/hello') {
    return new Response.seeOther('/hello');
  } else {
    return new Response.ok('');
  }
}

void main() {
  group("The dart:html adapter", () {
    test("Handles 30x responses as internal redirects (i.e. changes window.location)", () {
      var local = shelf_html.serve(_redirectHandler);
      // gmosx: I am not exactly sure why scheduleMicrotask is needed.
      scheduleMicrotask(() => expect(window.location.pathname, equals('/hello')));
    });
  });
}