"use strict";
module.exports = function (spotify) {

  var dummy = [
    "spotify:track:4pT1Ynb6upuZWqDowvW9sB",
    "spotify:track:1EiKmk4AwuNG2CmhQcCJ8k",
    "spotify:track:4BPorm0Z0NPsnqeQpfua6h"
  ];

  function next(){
    return spotify.createFromLink(dummy.shift());
  }

  return {
    next: next
  };
};
