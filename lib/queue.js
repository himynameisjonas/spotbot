"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);

  var queue = [
  ];

  function next(){
    return queue.shift();
  }

  function add(uri){
    queue.push(new Track(uri));
  }

  function tracks(){
    return queue.map(function(track){
      return track.json()
    });
  }

  return {
    next: next,
    add: add,
    tracks: tracks
  };
};
