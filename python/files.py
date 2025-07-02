import globals
import mp3

class MusicFolder:
  """
  A class to manage the user's music folder.

  This class holds the music folder location and its contents.

  The folder is scanned for subfolders and their contents on construction.
  The subfolders are treated as artists and each subfolder file is treated as a song.
  e.g. `~/music/keane/hopes and fears/bend and brake.mp3`
  The songs are sorted by track number.

  The class provides a method to get all songs and all albums.
  """
  
  Directory musicDir = Directory('/');
  List<Artist> artists = [];
  
  MusicFolder([String? path]) {
    if (path != null) {
      musicDir = Directory(path);

      if (!musicDir.existsSync()) {
        musicDir = Directory('${globals.userHomeDir}/music');
      }
    } else {
      musicDir = Directory('${globals.userHomeDir}/music');
    }


    if (!musicDir.existsSync()) {
      musicDir = Directory('${globals.userHomeDir}/Music');

      if (!musicDir.existsSync()) {
        print('no music found under ~/Music');
        exit(1);
      }
    }

    artists = musicDir.listSync(
    ).whereType<Directory>(
    ).map(
      (artist) => Artist(artist.path)
    ).toList();
  }

  
  /// Returns a list of all songs in the music folder.
  ///
  /// The list is sorted alphabetically by song title.
  List<MP3> getAllSongs() {
    List<MP3> songs = [];

    for (Artist artist in artists) {
      for (Album album in artist.albums) {
        songs.addAll(album.songs);
      }
    }

    return songs.toList()..sort(
      (song1, song2) => (song1.metaData.title ?? '<Unknown>').compareTo(song2.metaData.title ?? '<Unknown>')
    );
  }

  /// Returns a list of all albums in the music folder.
  ///
  /// The list is sorted first by artist name and then by album name.
  List<Album> getAllAlbums() {
    List<Album> albums = [];

    for (Artist artist in artists) {
      albums.addAll(artist.albums);
    }

    return albums.toList()..sort(
      (album1, album2) => album1.artist.compareTo(album2.artist) == 0
        ? album1.name.compareTo(album2.name)
        : album1.artist.compareTo(album2.artist)
    );
  }
}

  /// A class to manage an artist's music folder.
  ///
  /// This class holds the artist folder location and its contents.
  ///
  /// The folder is scanned for subfolders and their contents on construction.
  /// The subfolders are treated as albums and each subfolder file is treated as a song.
  /// e.g. `~/music/keane/hopes and fears/bend and brake.mp3`
  /// The songs are sorted by track number.
class Artist {
  List<Album> albums = [];
  String name = '<Unknown>';

  Artist(String path) {
    name = path.split('/').last;
    albums = Directory(
      path
    ).listSync(
    ).whereType<Directory>(
    ).map(
      (album) => Album(album.path, name)
    ).toList();
  }
}

  /// A class to manage an album.
  ///
  /// This class holds the album location and its contents.
  ///
  /// The folder is scanned for files and their contents on construction.
  /// The files are treated as songs and sorted by track number.
class Album {
  List<MP3> songs = [];
  String name = '<Unknown>';
  String artist;

  Album(String path, this.artist) {
    name = path.split('/').last;
    songs = Directory(
      path
    ).listSync(
    ).whereType<File>(
    ).where(
      (file) => file.path.endsWith('.mp3')
    ).map(
      (mp3) => MP3(mp3.path)
    ).toList();
  }
}
