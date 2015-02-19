"use strict";
module.exports = function (spotify) {
  var Track = require("./track")(spotify);
  var firebaseRef = require("./firebase").child("playlist");

  var queue   = [],
      tracks  = [],
      shuffle = false,
      name,
      playlistUri;

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
      var uri = queue.shift();
      if (uri) {
        return new Track(uri)
      };
    } else if(tracks.length) {
      populateQueue();
      var uri = queue.shift();
      if (uri) {
        return new Track(uri)
      };
    }
  }

  function change(uri){
    firebaseRef.child("shuffle").set(false);
    firebaseRef.child("tracks").remove();
    firebaseRef.child("name").remove();
    playlistUri = uri;
    queue  = [];
    tracks = [];
    fetchTracks();
  }

  function fetchTracks(){
    var object = spotify.createFromLink(playlistUri);
    if (playlistUri.match(/:album:/)) {
      object.browse(function(err, browsedAlbum){
        name = browsedAlbum.artist.name + " - " + object.name;
        tracks = browsedAlbum.tracks.map(function(track){
          return track.link
        });
        firebaseRef.child("tracks").set(tracks);
        firebaseRef.child("name").set(name);
      });
    } else {
      if (object.isLoaded) {
        loadPlaylist(object);
      } else {
        spotify.waitForLoaded([object], loadPlaylist);
      }
    }
    populateQueue();
  }

  function loadPlaylist(playlist){
    firebaseRef.child("name").set(playlist.name);
    tracks = playlist.getTracks().map(function(track){
      return track.link;
    });
    firebaseRef.child("tracks").set(tracks);
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
  };
};
