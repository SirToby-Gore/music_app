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
  MP3? currentSong;

  Screen screen;

  PlayManager(this.screen);

  /// Adds a song to the play queue.
  ///
  /// [song] is the MP3 object to be added.
  void addToPlayQueue(MP3 song) async {
    playQueue.add(song);
  }

  /// Starts playing songs from the play queue sequentially.
  ///
  /// It stops the current song, updates the current song from the queue,
  /// and waits for its duration to complete before moving to the next song.
  void startPlayQueue() async {
    while (playQueue.isNotEmpty) {
      await currentSong?.stop();
      sleep(const Duration(milliseconds: 50));

      currentSong = playQueue.first;
      playQueue.removeAt(0);

      changeCurrentSong(currentSong!);

      while ((currentSong?.elapsedEstimate ?? double.infinity) < (currentSong?.metaData.duration?.inSeconds ?? 0)) {
        await Future.delayed(const Duration(seconds: 1));
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Pauses the song that is currently at the front of the play queue.
  void pausePlayQueue() async {
    await playQueue.firstOrNull?.pause();
  }

  /// Stops the song that is currently at the front of the play queue.
  void stopPlayQueue() async {
    await playQueue.firstOrNull?.stop();
  }

  /// Resumes the song that is currently at the front of the play queue.
  void resumePlayQueue() async {
    playQueue.firstOrNull?.resume();
  }

  /// Replaces the current play queue with a new one and starts playback.
  ///
  /// [playQueue] is the new list of MP3 objects to be played.
  void newPlayQueue(List<MP3> playQueue) async {
    stopPlayQueue();
    await currentSong?.stop();

    this.playQueue = playQueue;

    startPlayQueue();
  }

  /// Changes the current song to [song] and starts playing it.
  ///
  /// Displays an error message on the screen if the song fails to play.
  void changeCurrentSong(MP3 song) async {
    await currentSong?.stop();
    sleep(const Duration(milliseconds: 50));

    currentSong = song;
    screen.showPlaying(currentSong);

    MP3StatusCode code = await currentSong!.start();

    if (code == MP3StatusCode.failure) {
      screen.showErrorMessage('Error playing - $currentSong');
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
}
