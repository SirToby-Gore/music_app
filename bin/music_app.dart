import 'package:music_app/mp3.dart';
import 'package:music_app/music_app.dart';
import 'package:music_app/files.dart';

dynamic defaultKey(MapEntry<String, Function> entry) => entry.key;

Map<String, Function> sortMap(Map<String, Function> map, Function(MapEntry<String, Function>) key) {
  return Map.fromEntries(
    map.entries.toList()
      ..sort((e1, e2) {
        if (e1.key.startsWith('<') && e1.key.endsWith('>')) {
          return e2.key.startsWith('<') && e2.key.endsWith('>') ? key(e1).compareTo(key(e2)) : -1;
        } else if (e2.key.startsWith('<') && e2.key.endsWith('>')) {
          return 1;
        } else {
          return key(e1).compareTo(key(e2));
        }
      })
  );
}

String getTrackRoundedNumber(int trackNumber) {
  String newTrackNumber = trackNumber.toString();

  while (newTrackNumber.length < 2) {
    newTrackNumber = '0$newTrackNumber';
  }

  return newTrackNumber;
}

Map<String, Function> getAlbumSubOptions(MusicApp app, Album album) {
  Map<String, Function> options = {
    '<Play all>': () {
      app.playManager.newPlayQueue(
        album.songs.toList()..sort(
          (MP3 song1, MP3 song2) => (song1.metaData.trackNumber ?? 0).compareTo(song2.metaData.trackNumber ?? 0)
        )
      );
    },
    '<Shuffle all>': () {
      app.playManager.newPlayQueue(
        album.songs.toList()..shuffle()
      );
    }
  };

  int unknownCounter = 1;

  for (MP3 song in album.songs) {
    options['${getTrackRoundedNumber(song.metaData.trackNumber ?? 0)} - ${song.metaData.title ?? 'Unknown - ${unknownCounter++}'}'] = () {
      app.playManager.changeCurrentSong(song);
    };
  }

  return sortMap(options, defaultKey);
}

Map<String, Function> getArtistSubOptions(MusicApp app, Artist artist) {
  Map<String, Function> options = {
    '<Play all>': () {
      List<MP3> songs = [];

      for (Album album in artist.albums) {
        songs.addAll(album.songs);
      }

      songs.sort((MP3 song1, MP3 song2) {
        int albumCompare = (song1.metaData.album ?? '').compareTo(song2.metaData.album ?? '');
        if (albumCompare != 0) {
          return albumCompare;
        } else {
          return (song1.metaData.trackNumber ?? 0).compareTo(song2.metaData.trackNumber ?? 0);
        }
      });

      app.playManager.newPlayQueue(songs);
    },
    '<Shuffle all>': () {
      List<MP3> songs = [];

      for (Album album in artist.albums) {
        songs.addAll(album.songs);
      }

      songs.shuffle();

      app.playManager.newPlayQueue(songs);
    }
  };

  for (Album album in artist.albums) {
    options[album.name] = () {
      app.listOptions(
        getAlbumSubOptions(app, album),
        title: 'Album - ${album.name}'
      );
    };
  }

  return sortMap(
    options,
    defaultKey
  );
}

Map<String, Function> getArtistsOptions(MusicApp app) {
  Map<String, Function> options = {};

  for (Artist artist in app.playManager.musicFolder.artists) {
    options[artist.name] = () {
      app.listOptions(
        getArtistSubOptions(app, artist),
        title: '${artist.name} - Albums'
      );
    };
  }

  return sortMap(
    options,
    defaultKey
  );
}

Map<String, Function> getSongsOptions(MusicApp app) {
  Map<String, Function> options = {
    '<Play all>': () {
      app.playManager.newPlayQueue(
        app.playManager.getAllSongs()..sort(
          (MP3 song1, MP3 song2) => (song1.metaData.title ?? '').compareTo(song2.metaData.title ?? '')
        )
      );
    },
    '<Shuffle all>': () {
      app.playManager.newPlayQueue(
        app.playManager.getAllSongs()..shuffle()
      );
    }
  };

  int unknownCounter = 0;

  for (MP3 song in app.playManager.getAllSongs()) {
    options['${song.metaData.title ?? 'Unknown ${unknownCounter++}'} - ${song.metaData.artist ?? 'Unknown'}'] = () {
      app.playManager.changeCurrentSong(song);
    };
  }

  return sortMap(
    options,
    defaultKey
  );
}

Map<String, Function> getAlbumOptions(MusicApp app) {
  Map<String, Function> options = {
    '<Play all>': () {
      app.playManager.newPlayQueue(
        app.playManager.getAllSongs()..sort(
          (song1, song2) {
            int albumCompare = (song1.metaData.album ?? '').compareTo(song2.metaData.album ?? '');
            if (albumCompare != 0) {
              return albumCompare;
            } else {
              return (song1.metaData.trackNumber ?? 0).compareTo(song2.metaData.trackNumber ?? 0);
            }
          }
        )
      );
    },
    '<Shuffle all>': () {
      List<Album> albums = app.playManager.getAllAlbums()..shuffle();
      List<MP3> playQueue = [];

      for (Album album in albums) {
        playQueue.addAll(album.songs..sort((MP3 tack1, MP3 track2) => (tack1.metaData.trackNumber ?? 0).compareTo(track2.metaData.trackNumber ?? 0)));
      }

      app.playManager.newPlayQueue(playQueue);
    },
  };

  List<Album> albums = [];

  for (Artist artist in app.playManager.musicFolder.artists) {
    albums.addAll(artist.albums);
  }

  int unknownCounter = 0;

  for (Album album in albums) {
    options['${album.songs.first.metaData.album ?? 'Unknown ${unknownCounter++}'} - ${album.artist}'] = () {
      app.listOptions(
        getAlbumSubOptions(
          app,
          album
        ),
        title: 'Album - ${album.songs.first.metaData.album ?? 'Unknown ${unknownCounter++}'} - ${album.artist}'
      );
    };
  }

  return sortMap(
    options,
    defaultKey
  );
} 

Map<String, Function> getRootOptions(MusicApp app) {
  return sortMap(
    {
      'Artists': () {
        app.listOptions(
          getArtistsOptions(app),
          title: 'Artists'
        );
      },
      'Songs': () {
        app.listOptions(
          getSongsOptions(app),
          title: 'Songs'
        );
      },
      'Albums': () {
        app.listOptions(
          getAlbumOptions(
            app
          ),
          title: 'Albums'
        );
      },
      '<Exit>': () {
        app.menu.exitMenu();
      },
    },
    defaultKey
  );
}

void main(List<String> arguments) {
  int maxItems = () {
    int height = MusicApp.screen.terminal.height - 20;

    if (height.isEven) {
      return height + 1;
    }

    return height;
  }();
  
  final app = MusicApp(
    defaultIndentOnItems: 1,
    defaultNumberOfItemsToShow: maxItems,
  );

  app
    ..startUp()
    ..listOptions(
      getRootOptions(app),
      title: 'Music app',
    );
}

