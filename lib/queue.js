"use strict";
module.exports = function (spotify) {

  var queue = [
  ];

  function next(){
    return spotify.createFromLink(queue.shift());
  }

  function add(uri){
    queue.push(uri);
  }

  function tracks(){
    return queue.map(function(uri){
      var track = spotify.createFromLink(uri);
      return {
        artists: track.artists,
        name: track.name
      };
    });
  }

  return {
    next: next,
    add: add,
    tracks: tracks
  };
};
