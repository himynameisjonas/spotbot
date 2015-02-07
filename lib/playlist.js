"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);
  var firebase = require("./firebase");

  var queue   = [],
      tracks  = [],
      shuffle = false,
      name,
      playlistUri;

  function next(){
    if (queue.length) {
      return queue.shift();
    } else if(tracks.length) {
      populateQueue();
      return queue.shift();
    }
  }

  function add(uri){
    playlistUri = uri;
    queue  = [];
    tracks = [];
    fetchTracks();
  }

  function setShuffle(input){
    if (input === undefined) {
      return shuffle;
    } else {
      shuffle = input;
      queue = [];
    }
  }

  function json(){
    if (playlistUri) {
      return {
        name: name,
        shuffle: shuffle,
        uri: playlistUri,
        tracks: tracks.map(function(track){
          return track.json();
        })
      };
    } else {
      return {};
    }
  }

  function fetchTracks(){
    var object = spotify.createFromLink(playlistUri);
    if (playlistUri.match(/:album:/)) {
      object.browse(function(err, browsedAlbum){
        name = browsedAlbum.artist.name + " - " + object.name;
        tracks = browsedAlbum.tracks.map(function(track){
          return new Track(track);
        });
        firebase.playlist(json());
      });
    } else {
      name = object.name;
      tracks = object.getTracks().map(function(track){
        return new Track(track);
      });
      firebase.playlist(json());
    }
    populateQueue();
  }

  function populateQueue(){
    if (shuffle) {
      var tempArray = tracks.slice();
      queue = shuffleArray(tempArray);
    } else {
      queue = tracks.slice();
    }
  }

  function shuffleArray(array) {
    var counter = array.length, temp, index;
    while (counter > 0) {
      index = Math.floor(Math.random() * counter);
      counter--;
      temp = array[counter];
      array[counter] = array[index];
      array[index] = temp;
    }
    return array;
  }

  firebase.playlist(json());

  return {
    next: next,
    add: add,
    shuffle: setShuffle
  };
};
