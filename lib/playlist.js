"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);

  var queue = [],
      tracks = [],
      playlistUri;

  function next(){
    if (queue.length) {
      return queue.shift();
    } else if(tracks.length) {
      queue = tracks.slice();
      return queue.shift();
    }
  }

  function add(uri){
    playlistUri = uri;
    queue  = [];
    tracks = [];
    fetchTracks();
  }

  function fetchTracks(){
    var playlist = spotify.createFromLink(playlistUri);
    tracks = playlist.getTracks().map(function(track){
      return new Track(track);
    });
    queue = tracks.slice();
  }

  return {
    next: next,
    add: add
  };
};
