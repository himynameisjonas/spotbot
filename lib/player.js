"use strict";
module.exports = function (spotify) {
  function start(){
    console.log("Starting player");
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
    return spotify.createFromLink("spotify:track:1EiKmk4AwuNG2CmhQcCJ8k");
  }

  return {
    start: start
  };
};
