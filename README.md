Shelf dart:html adapter
=======================

Shelf is the canonical way to structure backend applications but there is nothing
stoping you from using it at the client-side as well. This package provides 
an exterimentatl Shelf adapter to help you organize your frontend applications.

You can reuse Shelf middleware (e.g. shelf_route) or create custom middleware
for authentication and whatnot.


Example usage
-------------

```dart
import 'dart:html';

import 'package:shelf/shelf.dart';
import 'package:shelf_html/shelf_html.dart' as shelf_html;

var local;

Response helloHandler(request) {
  querySelector('#text').appendHtml('Hello <a id="link" href="/bye">bye</a><br/>');
  querySelector('#link').onClick.listen((e) {
    e.preventDefault();
    local.go((e.target as AnchorElement).href);
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

  local = shelf_html.serve(handler);
}
```

For a more involved example that leverages shelf_route and Polymer, hava a look 
[here](https://github.com/gmosx/shelf_html_example).


Status
------

The API is not stable. The intend is to strictly follow Dart and Shelf conventions while maintaining simplicity. We are open to any suggestions towards that goal.


Links
-----

* [Shelf_html_example](https://github.com/gmosx/shelf_html_example)
* [Shelf](http://pub.dartlang.org/packages/shelf)


Credits
-------

Copyright (c) 2014 George Moschovitis <george.moschovitis@gmail.com>.
