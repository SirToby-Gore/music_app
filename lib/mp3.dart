import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'dart:io';

/// Status codes for the MP3 class
///
/// [failure] - there was an error with the file
/// [warning] - there was a warning with the file
/// [success] - the file was processed successfully
enum MP3StatusCode {
  failure,
  warning,
  success,
}

/// A class representing an MP3 file
///
/// This class holds the MP3 file location and its metadata.
///
/// The file is scanned for metadata on construction.
/// The metadata is stored in the [metaData] field.
///
/// The class provides methods to play, pause, stop, resume and restart the MP3 file.
///
/// The class also provides methods to get the current elapsed time and the total duration of the MP3 file.
class MP3 {
  File file = File('');
  bool playing = false;
  bool open = false;
  bool muted = false;
  int elapsedEstimate = 0;

  AudioMetadata metaData = AudioMetadata(file: File(''));
  
  MP3(String path) {
    file = File(path);
    
    metaData = readMetadata(file, getImage: false);
  }

  Future<MP3StatusCode> start() async {
    if (open) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'ffplay',
      [
        '-nodisp',
        '-autoexit',
        '-hide_banner',
        '-loglevel',
        'quiet', 
        file.path,
      ],
    );

    open = true;
    playing = true;
    elapsedEstimate = 0;

    while (elapsedEstimate < (metaData.duration?.inSeconds ?? 0)) {
      if (playing) {
        elapsedEstimate++;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    return MP3StatusCode.success;
  }
  
  Future<MP3StatusCode> stop() async {
    if (!open) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'pkill',
      [
        '-9',
        'ffplay'
      ]
    );
    
    open = false;
    playing = false;

    return MP3StatusCode.success;
  }

  Future<MP3StatusCode> pause() async {
    if (!open) {
      return MP3StatusCode.failure;
    }
    
    if (!playing) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'pkill',
      [
        '-STOP',
        'ffplay'
      ]
    );

    playing = false;

    return MP3StatusCode.success;
  }

 Future<MP3StatusCode> resume() async {
     if (!open) {
      return MP3StatusCode.failure;
    }
    
    if (playing) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'pkill',
      [
        '-CONT',
        'ffplay'
      ]
    );

    playing = true;
    
    return MP3StatusCode.success;
  }

  Future<MP3StatusCode> restart() async {
    if (!open) {
      return MP3StatusCode.failure;
    }

    await stop();
    await start();

    return MP3StatusCode.success;
  }
  
  Future<MP3StatusCode> waitPlay() async {
    if (open) {
      return MP3StatusCode.failure;
    }
    
    open = true;

    await Process.start(
      'ffplay',
      [
        '-nodisp',
        '-autoexit',
        '-hide_banner',
        '-loglevel',
        'quiet',
        file.path,
      ],
    );
    
    while (elapsedEstimate < (metaData.duration?.inSeconds ?? 0)) {
      if (playing) {
        elapsedEstimate++;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    await stop();

    if (exitCode == 0) {
      open = false;
      return MP3StatusCode.success;
    } else {
      open = false;
      return MP3StatusCode.warning;
    }
  }
}
