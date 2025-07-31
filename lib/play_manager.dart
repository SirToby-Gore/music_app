import 'dart:io';
import 'package:music_app/mp3.dart';
import 'package:music_app/files.dart';
import 'package:music_app/screen.dart';

/// A class that manages the playback of songs.
///
/// This class handles the play queue, current song control, and
/// interaction with the screen for displaying the current playing song.
///
/// The play queue is a list of MP3 objects that is processed sequentially.
class PlayManager {
  List<MP3> playQueue = [];
  final MusicFolder musicFolder = MusicFolder();
  int currentSongPointer = 0;

  Screen screen;

  PlayManager(this.screen);

  /// Adds a song to the play queue.
  ///
  /// [song] is the MP3 object to be added.
  void addToPlayQueue(MP3 song) async {
    playQueue.add(song);
  }

  void startPlayQueue() async {
    if (currentSongPointer >= playQueue.length) {
      return;
    }

    screen.currentSong = playQueue[currentSongPointer];
    screen.currentSong!.start();
    
    while (currentSongPointer < playQueue.length) {
      while ((screen.currentSong?.elapsedEstimate ?? double.infinity) < (screen.currentSong?.metaData.duration?.inSeconds ?? 0)) {
        await Future.delayed(const Duration(seconds: 1));
      }

      await Future.delayed(const Duration(seconds: 1));
      nextSong();
    }
  }

  void nextSong() async {
    await screen.currentSong?.stop();
    await Future.delayed(const Duration(milliseconds: 50));

    screen.currentSong = null;

    currentSongPointer++;

    if (currentSongPointer == playQueue.length) {
      currentSongPointer--;
      return;
    }

    screen.currentSong = playQueue[currentSongPointer];

    screen.currentSong!.start();
  }

  void previousSong() async {
    await screen.currentSong?.stop();
    await Future.delayed(const Duration(milliseconds: 50));

    screen.currentSong = null;

    currentSongPointer--;

    if (currentSongPointer < 0) {
      currentSongPointer++;
      return;
    }

    screen.currentSong = playQueue[currentSongPointer];

    screen.currentSong!.start();
  }

  /// Pauses the song that is currently at the front of the play queue.
  void pausePlayQueue() async {
    await screen.currentSong?.pause();
  }

  /// Stops the song that is currently at the front of the play queue.
  void stopPlayQueue() async {
    await screen.currentSong?.stop();
  }

  /// Resumes the song that is currently at the front of the play queue.
  void resumePlayQueue() async {
    screen.currentSong?.resume();
  }

  /// Replaces the current play queue with a new one and starts playback.
  ///
  /// [playQueue] is the new list of MP3 objects to be played.
  void newPlayQueue(List<MP3> newPlayQueue) async {
    stopPlayQueue();
    await screen.currentSong?.stop();

    currentSongPointer = 0;

    playQueue = newPlayQueue;

    startPlayQueue();
  }

  /// Changes the current song to [song] and starts playing it.
  ///
  /// Displays an error message on the screen if the song fails to play.
  void changeCurrentSong(MP3 song) async {
    await screen.currentSong?.stop();
    sleep(const Duration(milliseconds: 50));

    screen.currentSong = song;
    screen.showPlaying(screen.currentSong);

    MP3StatusCode code = await screen.currentSong!.start();

    if (code == MP3StatusCode.failure) {
      screen.showErrorMessage('Error playing - ${screen.currentSong}');
    }
  }

  /// Returns a list of all albums available in the music folder.
  List<Album> getAllAlbums() {
    List<Album> albums = [];

    for (Artist artist in musicFolder.artists) {
      albums.addAll(artist.albums);
    }

    return albums.toList();
  }

  /// Returns a list of all songs available in the music folder.
  List<MP3> getAllSongs() {
    List<MP3> songs = [];

    for (Album album in getAllAlbums()) {
      songs.addAll(album.songs);
    }

    return songs.toList();
  }

  Set<String> getAllGenres() {
    Set<String> genres = {};

    for (MP3 song in getAllSongs()) {
      genres.addAll(song.metaData.genres);
    }

    return genres.where((String genre) => genre.isNotEmpty).toSet();
  }
}
