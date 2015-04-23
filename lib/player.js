"use strict";
module.exports = function (spotify, queue, playlist) {
  var firebase = require("./firebase");
  var loudness = require('loudness');
  var firebaseStatus = firebase.ref.child("player/playing");
  var firebaseNext = firebase.ref.child("player/next");
  var firebaseCurrent = firebase.ref.child("player/current_track");
  var firebaseVolume = firebase.ref.child("volume");
  var Track = require('./track')(spotify);

  firebaseStatus.on("value", function(data){
    console.log("Status updated", data.val());
    if (data.val() === true) {
      console.log("Player play");
      firebaseStatus.set(true);
      spotify.player.resume();
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

  firebaseCurrent.on("child_changed", function(data){
    var track = new Track(data.val());
    if(typeof(track.uri) !== "undefined") {
      console.log("Change track", track.uri);
      playNext(track);
    }
  });

  firebaseVolume.on("value", function(data){
    console.log("Set Volume to", data.val());
    loudness.setVolume(data.val(), function (err) {
      if (err) {
        console.log('Error', err)
      }
    });
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

  function pause(){
    console.log("Player pause");
    firebaseStatus.set(false);
    spotify.player.pause();
  }

  function stop(){
    pause();
    currentTrack();
  }

  function playNext(track){
    var track = track || nextTrack();
    if (track) {
      console.log("Playing track:", track.uri);
      try {
        spotify.player.play(track.getLink());
        firebaseStatus.set(true);
        currentTrack(track);
      } catch (e) {
        console.log(e);
        playNext();
      }
    } else {
      console.log("No track to play. Trying again in 1 second");
      spotify.player.pause();
      setTimeout(playNext, 1000);
    }
  }

  function nextTrack(){
    return queue.next() || playlist.next();
  }

  function currentTrack(track){
    if (track) {
      firebaseCurrent.set({uri: track.uri, started_at: firebase.firebase.ServerValue.TIMESTAMP});
    } else {
      firebaseCurrent.remove();
    }
  }

  return {
    start: start,
    stop: stop,
  };
};
