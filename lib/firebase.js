"use strict";
module.exports = function() {
  var Firebase = require("firebase");
  return {
    firebase: Firebase,
    ref: new Firebase(process.env.FIREBASE_URL || process.env.FIREBASE_URI)
  };
}();
