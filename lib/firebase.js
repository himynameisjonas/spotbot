"use strict";
module.exports = function() {
  var Firebase = require("firebase");
  var ref = new Firebase(process.env.FIREBASE_URL);

  function currentTrack(track){
    post("current_track", track);
  }

  function post(path, data){
    if (ref) {
      ref.child(path).set(data);
    }
  }

  return {
    currentTrack: currentTrack,
    ref: ref
  };
}();
