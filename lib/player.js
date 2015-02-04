"use strict";
module.exports = function (spotify) {
  var queue = require("./queue")(spotify);

  function start(){
    console.log("Starting player");

    spotify.player.on({
        endOfTrack: playNext
    });

    playNext();
  }

  function playNext(){
    var track = nextTrack();
    if (track) {
      console.log("Playing track:", track.artists[0].name, "-", track.name);
      spotify.player.play(track);
    } else {
      console.log("No track to play. Trying again in 1 second");
      setTimeout(playNext, 1000);
    }
  }

  function nextTrack(){
    return queue.next();
  }

  return {
    start: start
  };
};
