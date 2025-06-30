import 'package:music_app/globals.dart' as globals;
import 'package:music_app/mp3.dart';
import 'dart:io';

class MusicFolder {
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
