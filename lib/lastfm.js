"use strict";
module.exports = function() {
  var Scribbler = require("scribble");
  var scrobbler;

  if (process.env.LASTFM_API_KEY) {
    scrobbler = new Scribbler(
      process.env.LASTFM_API_KEY,
      process.env.LASTFM_API_SECRET,
      process.env.LASTFM_USERNAME,
      process.env.LASTFM_PASSWORD
    );

    scrobbler.MakeSession(function(key){
      scrobbler.sessionKey = key;
    });

  } else {
    console.log("Skipping Last.fm");
  }

  function prepareSong(track){
    var artists = track.artists().join(", ");
    var title = track.title();

    if (artists && title) {
      return {
        artist: artists,
        track: title,
        duration: track.duration(),
      };
    }
  }

  function nowPlaying(track){
    var song = prepareSong(track);
    if (scrobbler && song) {
      console.log("scrobbling (now playing)", song);
      scrobbler.NowPlaying(song);
    }
  }

  function scrobble(track){
    var song = prepareSong(track);

    if (scrobbler && song) {
      console.log("scrobbling", song);
      scrobbler.Scrobble(song);
    }
  }

  return {
    nowPlaying: nowPlaying,
    scrobble: scrobble
  };
}();
