"use strict";
module.exports = function(spotify){
  function Track(uri) {
    this.uri = uri;
  }

  Track.prototype.json = function() {
    var track = this.getLink()
    return {
      artists: track.artists,
      name: track.name
    };
  };

  Track.prototype.getLink = function() {
    if (this.link) {
      return this.link;
    } else {
      console.log("fetching link")
      this.link = spotify.createFromLink(this.uri);
      return this.link;
    }
  };

  return Track;
}
