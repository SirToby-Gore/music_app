import 'dart:io';

import 'package:music_app/mp3.dart';
import 'package:music_app/files.dart';
import 'package:music_app/screen.dart';

class PlayManager {
  List<MP3> playQueue = [];
  final MusicFolder musicFolder = MusicFolder();
  MP3? currentSong;

  Screen screen;

  PlayManager(this.screen);
  
  void addToPlayQueue(MP3 song) async {
    playQueue.add(song);
  }

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

  void pausePlayQueue() async {
    await playQueue.firstOrNull?.pause();
  }

  void stopPlayQueue() async {
    await playQueue.firstOrNull?.stop();
  }

  void resumePlayQueue() async {
    playQueue.firstOrNull?.resume();
  }

  void newPlayQueue(List<MP3> playQueue) async {
    stopPlayQueue();
    await currentSong?.stop();

    this.playQueue = playQueue;

    startPlayQueue();
  }

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

  List<Album> getAllAlbums() {
    List<Album> albums = [];

    for (Artist artist in musicFolder.artists) {
      albums.addAll(artist.albums);
    }

    return albums.toList();
  }

  List<MP3> getAllSongs() {
    List<MP3> songs = [];

    for (Album album in getAllAlbums()) {
      songs.addAll(album.songs);
    }

    return songs.toList();
  }
}