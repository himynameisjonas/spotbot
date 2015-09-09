"use strict";
module.exports = function (spotify, queue, playlist) {
  var firebase = require("./firebase");
  var loudness = require("loudness");
  var lastfm = require("./lastfm");
  var firebaseStatus = firebase.ref.child("player/playing");
  var firebaseNext = firebase.ref.child("player/next");
  var firebaseCurrent = firebase.ref.child("player/current_track");
  var firebaseVolume = firebase.ref.child("volume");
  var Track = require("./track")(spotify);
  var currentTrack = null;

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
      if (!currentTrack || track.uri !== currentTrack.uri ) {
        console.log("Change track", track.uri);
        playNext(track);
      }
    }
  });

  firebaseVolume.on("value", function(data){
    if (data.val() !== null) {
      console.log("Set Volume to", data.val());
      loudness.setVolume(data.val(), function (err) {
        if (err) {
          console.log("Error", err);
        }
      });
    }
  });

  function start(){
    console.log("Starting player");
    firebaseStatus.set(true);

    setCurrentTrack();

    spotify.player.on({
        endOfTrack: scrobbleAndPlayNext
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
    setCurrentTrack();
  }

  function scrobbleAndPlayNext(){
    lastfm.scrobble(currentTrack);
    playNext();
  }

  function playNext(track){
    var trackToPlay = track || nextTrack();
    if (trackToPlay) {
      console.log("Playing track:", trackToPlay.uri);
      try {
        spotify.player.play(trackToPlay.getLink());
        firebaseStatus.set(true);
        setCurrentTrack(trackToPlay);
      } catch (e) {
        console.log(e);
        playNext();
      }
    } else {
      console.log("No track to play. Trying again in 1 second");
      pause();
      setTimeout(playNext, 1000);
    }
  }

  function nextTrack(){
    return queue.next() || playlist.next();
  }

  function setCurrentTrack(track){
    if (track) {
      currentTrack = track;
      firebaseCurrent.set({uri: track.uri, started_at: firebase.firebase.ServerValue.TIMESTAMP});

      if (track.isLoaded) {
        console.log("isLoaded");
        lastfm.nowPlaying(track);
      } else {
        setTimeout(function(){
          lastfm.nowPlaying(track);
        }, 1000);
      }
    } else {
      currentTrack = null;
      firebaseCurrent.remove();
    }
  }

  return {
    start: start,
    stop: stop,
  };
};
