"use strict";
module.exports = function (player, queue) {
  var express = require("express");
  var bodyParser = require("body-parser");
  var app = express();

  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  app.get("/", function (req, res) {
    res.json({text: "Hello World!"});
  });

  app.route("/queue/tracks")
    .post(function(req, res){
      if (req.body.uri) {
        queue.add(req.body.uri);
        res.status(201);
      } else {
        res.status(400);
      }
    })
    .get(function(req, res){
      res.json(queue.tracks());
    });

  var server = app.listen(3000, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Api server listening at http://%s:%s", host, port);
  });
};
