"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);

  var queue = [
  ];

  function next(){
    var uri = queue.shift();
    if (uri) {
      return new Track(uri);
    }
  }

  function add(uri){
    queue.push(uri);
  }

  function tracks(){
    return queue.map(function(uri){
      return new Track(uri).json()
    });
  }

  return {
    next: next,
    add: add,
    tracks: tracks
  };
};
