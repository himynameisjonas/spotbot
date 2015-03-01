# Spotbot
A Spotify player with a Firebase integration. Perfect for an office where everyone can control the player and enqueue tracks. Great together with [spotbot-client](https://github.com/himynameisjonas/spotbot-client).

## Features/Short facts
* Start/Stop audio (of course!)
* Add tracks to a queue.
* Set a playlist or an album as the current playlist.
* Plays from the queue first and fallbacks to the playlist/album when the queue is empty.
* Stores state/queue in Firebase.
* Use a client ([spotbot-client](https://github.com/himynameisjonas/spotbot-client)) to control the player via the firebase connection.


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

### Install Libspotify/node-spotify
See [node-spotify](https://github.com/FrontierPsychiatrist/node-spotify/blob/v0.7.0/README.md) for more information.

#### Install libspotify on a Mac
1. `brew install homebrew/binary/libspotify`
2. `sudo ln -s /usr/local/opt/libspotify/lib/libspotify.12.1.51.dylib /usr/local/opt/libspotify/lib/libspotify`


## Web client
Use [spotbot-client](https://github.com/himynameisjonas/spotbot-client) for an easy way to controll the player
