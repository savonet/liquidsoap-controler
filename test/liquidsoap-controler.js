http = require("http");

auth = new Buffer("test:test").toString("base64")

var headers = {
  "Accept": "application/json",
  "Authorization": "Basic " + this.auth
}

var options = {
  host: 'localhost',
  port: 8080,
  path: '/request/queue/foo',
  headers: headers,
  method: 'PUT'
};

var execute = function (data, after) {
  var req = http.request(options, function(res) {
    console.log('STATUS: ' + res.statusCode);
    console.log('HEADERS: ' + JSON.stringify(res.headers));
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
      console.log('BODY: ' + chunk);
    });
    res.on('end', function (chunk) {
      after();
    });
  });

  req.on('error', function(e) {
    console.log('problem with request: ' + e.message);
  });

  // write data to request body
  req.end(data);
}

var push = function () {
  options.method = "POST";
  options.path   = "/requests/foo";

  var data = JSON.stringify(["/tmp/foo.mp3"]);

  data = JSON.stringify(data);

  options.headers["Content-Type"] =  "application/json";
  options.headers["Content-Length"] = data.length;
 
  var after = function () { console.log("all done!"); };

  execute(data, after);
}

var output = function () {
  options.path = "/output/ao/foo";

  execute(null, push);
};

var mksafe = function () {
  options.path = "/mksafe/foo";

  execute(null, output);
};

execute(null, mksafe);
