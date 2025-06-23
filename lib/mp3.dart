import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'dart:io';

enum MP3StatusCode {
  failure,
  warning,
  success,
}

class MP3 {
  File file = File('');
  bool playing = false;
  bool open = false;
  bool muted = false;
  bool finished = false;

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
        '-loglevel', 'quiet', 
        file.path,
      ],
    );

    open = true;
    playing = true;

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

  Future<MP3StatusCode> fastForward() async {
    if (!open) {
      return MP3StatusCode.failure;
    }
    
    await Process.start(
      'pkill',
      [
        '-USR1',
        'ffplay'
      ]
    );

    return MP3StatusCode.success;
  }

  Future<MP3StatusCode> rewind() async {
    if (!open) {
      return MP3StatusCode.failure;
    }
    
    await Process.start(
      'pkill',
      [
        '-USR2',
        'ffplay'
      ]
    );

    return MP3StatusCode.success;
  }

  Future<MP3StatusCode> mute() async {
    if (!open) {
      return MP3StatusCode.failure;
    }

    if (muted) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'pkill',
      [
        '-USR3',
        'ffplay'
      ]
    );

    muted = true;
    
    return MP3StatusCode.success;
  }

  Future<MP3StatusCode> unmute() async {
    if (!open) {
      return MP3StatusCode.failure;
    }

    if (!muted) {
      return MP3StatusCode.warning;
    }
    
    await Process.start(
      'pkill',
      [
        '-USR3',
        'ffplay'
      ]
    );
    
    muted = false;
    
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

    int timeLeft = metaData.duration?.inSeconds ?? 0;

    while (timeLeft > 0) {
      if (playing) {
        timeLeft--;
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
