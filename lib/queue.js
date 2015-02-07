"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);
  var firebase = require("./firebase");

  var queue = [];

  function next(){
    var nextTrack = queue.shift();
    if (nextTrack) {
      firebase.queue(tracks());
      return nextTrack;
    }
  }

  function add(uri){
    queue.push(new Track(uri));
    firebase.queue(tracks());
  }

  function tracks(){
    return queue.map(function(track){
      return track.json();
    });
  }

  firebase.queue(tracks());

  return {
    next: next,
    add: add,
    tracks: tracks
  };
};
