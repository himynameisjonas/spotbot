"use strict";
module.exports = function() {
  var Firebase = require("firebase");

  if (process.env.FIREBASE_URL) {
    var ref = new Firebase(process.env.FIREBASE_URL);
  }

  function currentTrack(track){
    post("current_track", track);
  }

  function queue(tracks){
    post("queue", tracks);
  }

  function playlist(data){
    post("playlist", data);
  }

  function post(path, data){
    if (ref) {
      ref.child(path).set(data);
    }
  }

  return {
    currentTrack: currentTrack,
    queue: queue,
    playlist: playlist
  };
}();
