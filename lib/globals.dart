import 'dart:io';

/// Returns the user's home directory path based on the platform.
///
/// On Windows, it retrieves the 'USERPROFILE' environment variable.
/// On other platforms, it retrieves the 'HOME' environment variable.
final String userHomeDir = () {
  if (Platform.isWindows) {
    return Platform.environment['USERPROFILE'] ?? '';
  } else {
    return Platform.environment['HOME'] ?? '';
  }
}();

/// Has the menu been initialised yet?
bool menuInitialised = false;