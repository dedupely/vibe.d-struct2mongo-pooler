```
import vibe.vibe;
import vibedstruct2mongo;
import struct2mongo;

MongoDBConnection mongoPool;

shared static this()
{
  mongoPool = new MongoDBConnection("mongodb://localhost", 2);

  auto settings = new HTTPServerSettings;
  settings.port = 8089;
  settings.bindAddresses = ["::1", "127.0.0.1"];
  listenHTTP(settings, &hello);

  logInfo("Please open http://127.0.0.1:8080/ in your browser.");
  runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
  res.writeBody("Hello, World!");

  auto col = Col (mongoPool[`newBase`][`newCollection`]);

  struct Example {
    int a = 0;
  }

  col.insert(Example(5));
}
```