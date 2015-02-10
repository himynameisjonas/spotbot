"use strict";
module.exports = function (spotify, queue, playlist) {
  var firebase = require("./firebase");
  var firebaseStatus = firebase.child("player/playing");
  var firebaseNext = firebase.child("player/next");
  var firebaseCurrent = firebase.child("player/current_track");

  firebaseStatus.on("value", function(data){
    console.log("Status updated", data.val());
    if (data.val() === true) {
      play();
    } else if (data.val() === false) {
      pause();
    }
  });
  firebaseNext.on("value", function(data){
    console.log("Next updated", data.val());
    if (data.val() === true) {
      playNext();
      firebaseNext.set(false);
    }
  });

  function start(){
    console.log("Starting player");
    firebaseStatus.set(true);

    currentTrack();

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
      firebaseStatus.set(true);
      currentTrack(track);
    } else {
      console.log("No track to play. Trying again in 1 second");
      spotify.player.pause();
      setTimeout(playNext, 1000);
    }
  }

  function play(){
    console.log("Player play");
    firebaseStatus.set(true);
    spotify.player.resume();
  }

  function pause(){
    console.log("Player pause");
    firebaseStatus.set(false);
    spotify.player.pause();
  }

  function nextTrack(){
    return queue.next() || playlist.next();
  }

  function currentTrack(track){
    if (track) {
      firebaseCurrent.set(track.uri);
    } else {
      firebaseCurrent.set(null);
    }
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
