"use strict";
module.exports = function (spotify, queue, playlist) {
  var firebase = require("./firebase");

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
      console.log("Playing track:", track.artists(), "-", track.title());
      spotify.player.play(track.getLink());
      currentTrack(track);
    } else {
      console.log("No track to play. Trying again in 1 second");
      spotify.player.pause();
      setTimeout(playNext, 1000);
    }
  }

  function play(){
    console.log("Player play");
    spotify.player.resume();
  }

  function pause(){
    console.log("Player pause");
    spotify.player.pause();
  }

  function nextTrack(){
    return queue.next() || playlist.next();
  }

  function currentTrack(track){
    firebase.currentTrack(track);
  }

  return {
    start: start,
    play: play,
    pause: pause,
    next: playNext,
    queue: queue,
    playlist: playlist
  };
};
