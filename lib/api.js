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
        res.sendStatus(201);
      } else {
        res.sendStatus(400);
      }
    })
    .get(function(req, res){
      res.json(queue.tracks());
    });

  app.put("/player/start", function(req, res){
    player.play();
    res.sendStatus(200);
  });

  app.put("/player/stop", function(req, res){
    player.pause();
    res.sendStatus(200);
  });

  var server = app.listen(3000, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Api server listening at http://%s:%s", host, port);
  });
};
