import 'dart:html';

import 'package:shelf/shelf.dart';
import 'package:shelf_html/shelf_html.dart' as shelf_html;

Response handler(Request request) {
  return new Response.ok('');
}

void main() {
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(handler);

  shelf_html.serve(pipeline).then((app) {
  });
}