import 'dart:html';

import 'package:unittest/unittest.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf_html/shelf_html.dart' as shelf_html;

Response redirectHandler(Request request) {
  return new Response.seeOther('/hello');
}

void main() {
  group("The dart:html adapter", () {
    test("Handles 30x responses as internal redirects (i.e. changes window.location)", () {
      shelf_html.serve(redirectHandler).then((l) {
        expect(window.location.pathname, equals('/hello'));
      });
    });
  });
}