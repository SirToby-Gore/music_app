import 'dart:io';

String userHomeDir = () {
  if (Platform.isWindows) {
    return Platform.environment['USERPROFILE'] ?? '';
  } else {
    return Platform.environment['HOME'] ?? '';
  }
}();

bool menuInitialised = false;