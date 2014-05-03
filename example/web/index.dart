import 'dart:html';

import 'package:shelf/shelf.dart';
import 'package:shelf_html/shelf_html.dart' as shelf_html;

var local;

Response helloHandler(request) {
  querySelector('#text').appendHtml('Hello <a id="link" href="/bye">bye</a><br/>');
  querySelector('#link').onClick.listen((e) {
    e.preventDefault();
//    local.get((e.target as AnchorElement).href);
    local.get('/bye');
  });
  return new Response.ok('');
}

Response byeHandler(request) {
  querySelector('#text').appendHtml('Bye<br/>');
  return new Response.ok('');
}

// A simple request router for demonstration purposes. In a real-world
// application you would use shelf_route.
Response router(Request request) {
  switch (request.url.path) {
    case '/hello':
      return helloHandler(request);

    case '/bye':
      return byeHandler(request);
  }

  return new Response.seeOther('/hello');
}

void main() {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  local = shelf_html.serve(handler, basePath: '/shelf_html/example/web');
}