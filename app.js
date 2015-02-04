"use strict";
require("dotenv").load();

var player = require("./lib/player");

var spotify = require("node-spotify")({
    appkeyFile: "./spotify_appkey.key",
    cacheFolder: "cache",
    settingsFolder: "settings"
});

process.on("SIGINT", function () {
  console.log("Logging out");
  spotify.logout();
});

var ready = function()  {
  console.log("Logged in");
  player(spotify).start();
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
