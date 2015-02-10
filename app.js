"use strict";
require("dotenv").load();

var spotify = require("node-spotify")({
    appkeyFile: "./spotify_appkey.key",
    cacheFolder: "cache",
    settingsFolder: "settings"
});
var queue = require("./lib/queue")(spotify);
var playlist = require("./lib/playlist")(spotify);
var player = require("./lib/player")(spotify, queue, playlist);

process.on("SIGINT", function () {
  console.log("Logging out");
  spotify.logout();
});

var ready = function()  {
  console.log("Logged in");
  player.start();
};

spotify.on({
  ready: ready,
  logout: function(){
    console.log("Logged out");
    process.exit(0);
  }
});

console.log("Logging in as:", process.env.SPOTIFY_USERNAME);
spotify.login(process.env.SPOTIFY_USERNAME, process.env.SPOTIFY_PASSWORD, false, false);
