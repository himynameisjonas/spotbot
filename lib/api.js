"use strict";
module.exports = function (player) {
  var express = require("express");
  var bodyParser = require("body-parser");
  var app = express();

  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  app.all("/*", function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    res.header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
    res.header("Access-Control-Allow-Credentials", true);
    next();
  });

  app.get("/", function (req, res) {
    res.json({text: "Hello World!"});
  });

  app.route("/queue/tracks")
    .post(function(req, res){
      if (req.body.uri) {
        player.queue.add(req.body.uri);
        res.sendStatus(201);
      } else {
        res.sendStatus(400);
      }
    })
    .get(function(req, res){
      res.json(player.queue.tracks());
    });

  app.put("/player/start", function(req, res){
    player.play();
    res.sendStatus(200);
  });

  app.put("/player/stop", function(req, res){
    player.pause();
    res.sendStatus(200);
  });

  app.put("/player/next", function(req, res){
    player.next();
    res.sendStatus(200);
  });

  app.post("/playlist", function(req, res){
    player.playlist.add(req.body.uri);
    res.sendStatus(201);
  });

  app.route("/playlist/shuffle")
    .get(function(req, res){
      res.json({shuffle: player.playlist.shuffle()});
    })
    .put(function(req, res){
      player.playlist.shuffle(true);
      res.json({shuffle: player.playlist.shuffle()});
    })
    .delete(function(req, res){
      player.playlist.shuffle(false);
      res.json({shuffle: player.playlist.shuffle()});
    });

  var server = app.listen(process.env.SERVER_PORT || 3000, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Api server listening at http://%s:%s", host, port);
  });
};
