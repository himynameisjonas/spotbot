"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);
  var firebase = require("./firebase");
  var firebaseRef = firebase.ref.child("playlist");

  var queue   = [],
      tracks  = [],
      shuffle = false,
      name,
      playlistUri;

  firebaseRef.child("tracks").set([]);

  firebaseRef.child("uri").on("value", function(data){
    change(data.val());
  });

  firebaseRef.child("shuffle").on("value", function(data){
    if (data.val() !== null) {
      shuffle = data.val();
      queue = [];
    } else {
      data.ref().set(false);
    }
  });

  function next(){
    if (queue.length) {
      return queue.shift();
    } else if(tracks.length) {
      populateQueue();
      return queue.shift();
    }
  }

  function change(uri){
    firebaseRef.child("shuffle").set(false);
    playlistUri = uri;
    queue  = [];
    tracks = [];
    firebaseRef.child("tracks").set([]);
    firebaseRef.child("name").set(null);
    fetchTracks();
  }

  function tracksAsJson(){
    return tracks.map(function(track){
      return track.uri;
    });
  }

  function fetchTracks(){
    var object = spotify.createFromLink(playlistUri);
    if (playlistUri.match(/:album:/)) {
      object.browse(function(err, browsedAlbum){
        name = browsedAlbum.artist.name + " - " + object.name;
        tracks = browsedAlbum.tracks.map(function(track){
          return new Track(track);
        });
        firebaseRef.child("tracks").set(tracksAsJson());
        firebaseRef.child("name").set(name);
      });
    } else {
      name = object.name;
      tracks = object.getTracks().map(function(track){
        return new Track(track);
      });
      firebaseRef.child("name").set(name);
      firebaseRef.child("tracks").set(tracksAsJson());
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

  return {
    next: next,
    add: change
  };
};
