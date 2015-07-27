# Spotbot
A Spotify player with a Firebase integration. Perfect for an office where everyone can control the player and enqueue tracks. Great together with [spotbot-client](https://github.com/himynameisjonas/spotbot-client).

## Features/Short facts
* Start/Stop audio (of course!)
* Add tracks to a queue.
* Set a playlist or an album as the current playlist.
* Plays from the queue first and fallbacks to the playlist/album when the queue is empty.
* Stores state/queue in Firebase.
* Use a client ([spotbot-client](https://github.com/himynameisjonas/spotbot-client)) to control the player via your browser.
* Last.fm scrobbling.


## Config/Setup
1. Checkout code `git clone https://github.com/himynameisjonas/spotbot.git`
2. Install Libspotify (see separate section)
3. Install node dependencies `npm install`
4. Provide a [Spotify app key](https://devaccount.spotify.com/my-account/keys/) as `spotify_appkey.key` (binary) in the project’s root.
5. Have a Spotify Premium account and a (free) Firebase account and config the player with a .env file:
```
SPOTIFY_USERNAME=xxx
SPOTIFY_PASSWORD=yyy
SERVER_PORT=3030
FIREBASE_URI=https://xxxx.firebaseio.com
```

### Optional Last.fm scrobbling
Enable scrobbling to Last.fm by setting the following environment variables.
```
LASTFM_API_KEY=XXX
LASTFM_API_SECRET=YYY
LASTFM_USERNAME=himynameisjonas
LASTFM_PASSWORD=xxx
```
Register an app on Last.fm to get the keys for `LASTFM_API_KEY` and `LASTFM_API_SECRET`.

### Install Libspotify/node-spotify
See [node-spotify](https://github.com/FrontierPsychiatrist/node-spotify/blob/v0.7.0/README.md) for more information.

#### Install libspotify on a Mac
1. `brew install homebrew/binary/libspotify`
2. `sudo ln -s /usr/local/opt/libspotify/lib/libspotify.12.1.51.dylib /usr/local/opt/libspotify/lib/libspotify`

## Api
Firebase nodes and their uses. Plase note that [arrays are a bit special in Firebase](https://www.firebase.com/blog/2014-04-28-best-practices-arrays-in-firebase.html)

- **player**
  - **current_track**
    - **uri** _read/write_ Uri to the currently playing track. Set uri to immediately change track.
    - **started_at** _read-only_ timestamp when the current track started playing
  - **playing** _read/write_ Boolean showing current status (playing/paused)
  - **next** _write_ Boolean. Set to true to skip to next track in queue/playlist. Will be set to false again as soon the player has changed track.
- **playlist**
  - **uri** _read/write_ URI to the current playlist/album. Set to a new URI/URL to change playlist/album.
  - **shuffle** _read/write_ Boolean to controll shuffle on/off for the current playlist.
  - **name** _read-only_ Name of the current playlist.
  - **tracks** _read-only_ Array of Uri:s of the current playlist’s tracks.
- **queue** _read/write_ Array of objects with an **uri** property. Add to enqueue new track, remove to drop a track from the queue.
- **volume** _read/write_ Volume as a String, 0 to 100

## Web client
Use [spotbot-client](https://github.com/himynameisjonas/spotbot-client) for an easy way to controll the player

## Volume Control
It uses [node-loudness](https://github.com/LinusU/node-loudness) to control the systems output volume. Supports Mac Os and Linux(Alsa)
