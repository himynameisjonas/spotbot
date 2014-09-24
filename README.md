# Spotbot
A Spotify player with a HTTP API and Firebase integration

## Features
* Start/Stop audio
* Add tracks to a play queue
* Set current playlist/album
* Scrobbles to Last.fm
* Sets current track, current playlist, track queue and player volume in Firebase, for others to fetch in realtime
* Everything controllable via a easy to use JSON api

## Config/Setup
### Required environment variables
```
SPOTIFY_USERNAME=xxx
SPOTIFY_PASSWORD=yyy
SERVER_PORT=3030
```

### Optional environment variables
```
LAST_FM_USERNAME=zzz
LAST_FM_PASSWORD=xxx
FIREBASE_URI=https://xxxx.firebaseio.com
```
