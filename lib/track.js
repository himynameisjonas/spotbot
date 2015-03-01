"use strict";
module.exports = function(spotify){
  function Track(uriOrObject) {
    if (typeof(uriOrObject) === "string") {
      this.uri = uriOrObject;
    } else {
      this.uri = uriOrObject.link;
      this.link = uriOrObject;
    }
  }

  Track.prototype.getLink = function() {
    if (this.link) {
      return this.link;
    } else {
      this.link = spotify.createFromLink(this.uri);
      return this.link;
    }
  };

  Track.prototype.json = function() {
    return {
      uri: this.uri,
      artists: this.artists(),
      title: this.title(),
      duration: this.duration(),
      image: this.image()
    };
  };

  Track.prototype.artists = function() {
    var track = this.getLink();
    if (track) {
      return track.artists.map(function(artist){
        return artist.name;
      });
    }
  };

  Track.prototype.title = function() {
    var track = this.getLink();
    if (track) {
      return track.name;
    }
  };

  Track.prototype.duration = function() {
    var track = this.getLink();
    if (track) {
      return track.duration * 1000;
    }
  };

  Track.prototype.image = function() {
    return "";
  };


  return Track;
};
