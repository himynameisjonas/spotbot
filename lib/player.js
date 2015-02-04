"use strict";
module.exports = function (spotify, queue) {
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
      console.log("Playing track:", track.uri);
      spotify.player.play(track.getLink());
      currentTrack(track)
    } else {
      console.log("No track to play. Trying again in 1 second");
      setTimeout(playNext, 1000);
    }
  }

  function nextTrack(){
    return queue.next();
  }

  function currentTrack(track){
    console.log("Setting currentTrack", track.json())
  }

  return {
    start: start
  };
};
