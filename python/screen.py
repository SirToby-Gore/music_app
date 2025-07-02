import 'dart:math';
import 'dart:io';
import 'package:music_app/text.dart';
import 'package:rich_stdout/rich_stdout.dart';
import 'package:music_app/mp3.dart';
import 'package:music_app/settings.dart';

/// A class to manage the screen.
///
/// This class holds the screen's terminal instance and dimensions.
///
/// The class provides methods to draw the screen border, display text and
/// menus, and show the current playing song.
///
/// The class also provides methods to clear the screen and show the play
/// controls.
class Screen {
  final Terminal terminal = Terminal();
  final String resetStyle = Ansi.construct([Effect.reset]);
  final String printItem = Settings.borderPrintItem;
  List<List<String>> screen = [];
  MP3? currentSong;

  int borderWidth = 0;
  int borderHeight = 0;

  int innerWidth = 0;
  int innerHeight = 0;
  
  Map<int, List<int>> border = Settings.borderBackgroundEffects;
  
  int innerSpace = 0;

  Screen() {
    borderWidth = border.length * printItem.length * 2;
    borderHeight = border.length * 2;

    innerWidth = terminal.width - borderWidth;
    innerHeight = terminal.height - borderHeight;

    _startShowPlaying();
  }

  /// Initializes the screen for the application.
  ///
  /// This method hides the cursor, calculates the dimensions of the screen,
  /// and sets up the initial border and content. It creates a grid of strings
  /// representing the screen, with each cell containing either a border character
  /// or a content character. The border is drawn based on the specified settings.
  ///
  /// It then displays a welcome message on the screen for a duration specified
  /// in the settings.
  void startUp() {
    terminal.hideCursor();
    
    screen = [];

    final int width = terminal.width;
    final int height = terminal.height;

    final int printWidth = width ~/ printItem.length;

    bool hasPrinted;

    for (int rowNumber = 0; rowNumber < height; rowNumber++) {
      List<String> row = [];

      for (int columnNumber = 0; columnNumber < printWidth; columnNumber++) {
        hasPrinted = false;
        
        for (int borderPointer = 0; borderPointer < border.length; borderPointer++) {
          if (
            rowNumber == borderPointer
            || rowNumber == height - (borderPointer + 1)
            || columnNumber == borderPointer
            || columnNumber == printWidth - (borderPointer + 1)
          ) {
            row.add('${Ansi.construct(border[borderPointer + 1]!)}$printItem$resetStyle');
            hasPrinted = true;
            break;
          }
        }

        if (!hasPrinted) {
          row.add(printItem);
        }
      }

      screen.add(row);
    }

    List<Line> titleScreenRaw = Settings.welcomeText.map(
      (line) => CenterLine([Text(line)], innerWidth)
    ).toList();

    drawBorder();
    
    Paragraph titleScreenText = CenterParagraph(
      titleScreenRaw,
      innerHeight,
    );

    writeTextFromCorner(titleScreenText);

    sleep(Settings.titleAndExitScreenDuration);
  }
  
  /// Draws a border around the screen.
  ///
  /// This function draws a border with the style of the border defined by
  /// [Settings.borderStyle].
  ///
  /// It can also display a song title in the top left corner by providing a song
  /// object. The song's title is displayed with the style of
  /// [Settings.titleStyle].
  ///
  /// The border is drawn with a spiral traversal and the drawing is delayed by
  /// [startDelay] seconds.
  ///
  /// Parameters:
  /// - `song`: An optional song to display its title in the top left corner.
  /// - `title`: An optional title to display in the top left corner. If present,
  ///            the `song` object is ignored.
  /// - `startDelay`: The delay in seconds before drawing the border. Defaults to 6.
  void drawBorder({MP3? song, String? title, int startDelay = 6}) {
    if (startDelay > 0) {
      Random random = Random();
      int delay = startDelay;

      terminal.clear();

      spiralTraverseAndApply(screen, (String tile, int row, int column) {
        terminal.moveCursor(column * printItem.length + 1, row + 1);
        terminal.print(tile, newLine: false);
        sleep(Duration(milliseconds: delay));

        if (random.nextInt(50) > 48 && delay > 0) {
          delay--;
        }
      });
    } else {
      terminal.moveCursor(0, 0);
      terminal.print(screen.map((row) => row.join()).join('\n'), newLine: false);
    }

    showCommands([
      'enter: play or select',
      'up, down, left, right, pg-up, pg-dn, home, end: change selection',
      'del, esc: back'
    ]);

    showPlayControls();

    showTitle(title ?? '');

    _showPlayState();
  }

  /// A method to traverse a matrix in a spiral order.
  ///
  /// This method is based on the [Spiral Matrix] algorithm.
  ///
  /// The traversal starts from the top left corner and goes in a spiral order outwards.
  ///
  /// The method takes a callback function that is called on each item in the matrix.
  /// The callback function takes three parameters: the item, the row of the item, and the column of the item.
  ///
  /// The method traverses the matrix in layers, starting from the top left corner.
  /// Each layer is traversed in the order of right, down, left, up.
  ///
  /// The method stops traversing the matrix when the top row and the left column
  /// have been traversed.
  ///
  /// [Spiral Matrix]: https://en.wikipedia.org/wiki/Spiral_matrix
  void spiralTraverseAndApply<T>(
      List<List<T>> matrix,
      Function(T item, int row, int col) callback
    ) {
      if (matrix.isEmpty || matrix[0].isEmpty) {
        return;
      }

      int top = 0;
      int bottom = matrix.length - 1; // Number of rows - 1
      int left = 0;
      int right = matrix[0].length - 1; // Number of columns - 1
      int layers = 0;

      while (top <= bottom && left <= right && layers < 7) {
        // Traverse Right (Top row)
        for (int col = left; col <= right; col++) {
          callback(matrix[top][col], top, col);
        }
        top++; // Move top boundary down

        // Traverse Down (Rightmost column)
        for (int row = top; row <= bottom; row++) {
          callback(matrix[row][right], row, right);
        }
        right--; // Move right boundary left

        // Traverse Left (Bottom row)
        // Check if there's still a bottom row to traverse to avoid duplicates
        if (top <= bottom) {
          for (int col = right; col >= left; col--) {
            callback(matrix[bottom][col], bottom, col);
          }
          bottom--; // Move bottom boundary up
        }

        // Traverse Up (Leftmost column)
        // Check if there's still a left column to traverse to avoid duplicates
        if (left <= right) {
          for (int row = bottom; row >= top; row--) {
            callback(matrix[row][left], row, left);
          }
          left++; // Move left boundary right
        }

        layers++; // Increment the layer count
      }
    }
  
  /// Writes the text from the corner of the screen.
  ///
  /// The text is written in the area defined by the [innerWidth] and [innerHeight]
  /// properties. The text is centred in this area.
  ///
  /// The text is written starting from the top left corner of the area.
  ///
  /// The method does not clear the screen before writing the text.
  void writeTextFromCorner(Paragraph text) {
    final int cursorColumnStart = (borderWidth ~/ 2) + 1;

    for (int linePointer = 0; linePointer < innerHeight; linePointer++) {
      terminal.moveCursor(
        cursorColumnStart,
        border.length + linePointer + 1 
      );

      terminal.print(' ' * innerWidth, newLine: false);

      if (linePointer < text.lines.length) {
        Line line = text.lines[linePointer];

        terminal.moveCursor(
          cursorColumnStart,
          border.length + linePointer + 1
        );

        terminal.print(line.render(), newLine: false);
      }
    }

    terminal.moveCursor(0, terminal.height); // moves the cursor to the bottom
  }
  
  /// Shows a list of commands on the screen.
  ///
  /// The commands are a list of strings. Each string is a command that can be
  /// entered by the user. The commands are displayed on the screen in a single
  /// line, separated by spaces.
  ///
  /// The method writes the commands in the area defined by the [innerWidth] and
  /// [innerHeight] properties. The text is centred in this area.
  ///
  /// The method does not clear the screen before writing the text.
  void showCommands(List<String> commands) {
    _printInBorder(
      CenterLine(
        [Text(commands.join('  '))],
        innerWidth
      ),
      1,
      false
    );
  }

  /// Shows the currently playing song.
  ///
  /// The method displays the song title in the area defined by the [innerWidth]
  /// and [innerHeight] properties. The text is centred in this area.
  ///
  /// The method does not clear the screen before writing the text.
  ///
  /// If [song] is not provided, the currently playing song is determined by the
  /// [currentSong] property.
  ///
  /// The method does not update the [currentSong] property.
  void showPlaying([MP3? song]) {
    currentSong = song;
  }
  
  /// Updates the play state of the screen.
  ///
  /// The method displays the play state in the area defined by the [innerWidth]
  /// and [innerHeight] properties. The text is centred in this area.
  ///
  /// The method does not clear the screen before writing the text.
  ///
  /// The method does not update the [currentSong] property.
  void _showPlayState() async {
    Line line = CenterLine([Text('<no song playing>')], innerWidth);

    const int lengthOfPlayBar = 15;

    if (currentSong != null) {
      List<Text> playBar = [
        Text('['),
        Text(List.generate(
          lengthOfPlayBar,
          (i) => (
            currentSong!.elapsedEstimate * lengthOfPlayBar / currentSong!.metaData.duration!.inSeconds
          ) >= i
          ? '#'
          : ' '
        ).join()),
        Text(']'),
      ];

      if (!currentSong!.playing) {
        playBar.insert(
          0, 
          Style([Effect.slowBlink])
        );

        playBar.add(
          Style([Effect.blinkOff])
        );
      }

      line = CenterLine(
        [
          Text([
            currentSong!.metaData.title ?? '',
            '-',
            currentSong!.metaData.artist ?? '',
            printItem,
          ].join(' ')),
          ...playBar
        ],
        innerWidth
      );
    }
    
    _printInBorder(
      line,
      3,
      false,
    );
  }

  /// Starts a loop that periodically updates the playing song display.
  ///
  /// The loop updates the display every second until the loop is stopped.
  /// The loop does not stop by itself and must be stopped manually.
  ///
  /// The loop is intended to be used with the [showPlaying] method to periodically
  /// update the display with the current playing song.
  void _startShowPlaying() async {
    while (true) {
      _showPlayState();

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Shows the play controls on the screen.
  ///
  /// The play controls are the commands that can be used to control the playback
  /// of songs. The play controls are displayed on the screen in a single line,
  /// separated by spaces.
  ///
  /// The method is intended to be used with the [showPlaying] method to periodically
  /// update the display with the current playing song.
  ///
  /// The method does not clear the screen before writing the text.
  void showPlayControls() {
    _printInBorder(
      CenterLine(
        [
          Text('space: play/pause  '),
          Text('n: next  '),
          Text('r: restart song'),
        ],
        innerWidth,
      ),
      2,
      false,
    );
  }
  
  /// Shows the title of the music app on the screen.
  ///
  /// The title is displayed with an underline style and centred on the screen.
  ///
  /// The method does not clear the screen before writing the text.
  ///
  /// Parameters:
  /// - `title`: The title of the music app to be displayed.
  void showTitle(String title) {
    _printInBorder(
      CenterLine(
        [
          Style([Effect.bold, Effect.underlined]),
          Text(title),
          Style([Effect.underlineOff]),
        ],
        innerWidth
      ),
      2,
      true
    );
  }

  /// Displays a debug message on the screen for a specified duration.
  ///
  /// The message is displayed in the area defined by the [innerWidth] property
  /// and is centred within this area. The message will be cleared after the
  /// specified display time.
  ///
  /// Parameters:
  /// - `message`: The debug message to display.
  /// - `displayTime`: The duration, in seconds, for which the message should be
  ///   displayed. Defaults to 5 seconds.
  void showDebug(String message, [int displayTime = 5]) async {
    _printInBorder(
      CenterLine(
        [
          Text(message)
        ],
        innerWidth,
      ),
      3,
      true
    );

    await Future.delayed(Duration(seconds: displayTime));

    _clearInBorder(1, true);
  }
  /// Displays an error message on the screen for a specified duration.
  ///
  /// The message is displayed in the area defined by the [innerWidth] property
  /// and is centred within this area. The message will be cleared after the
  /// specified display time.
  ///
  /// Parameters:
  /// - `message`: The error message to display.
  /// - `displayTime`: The duration, in seconds, for which the message should be
  ///   displayed. Defaults to 5 seconds.
  void showErrorMessage(String message, [int displayTime = 5]) async {
    _printInBorder(
      CenterLine(
        [
          Text(message)
        ],
        innerWidth
      ),
      3,
      true
    );

    await Future.delayed(Duration(seconds: displayTime));

    _clearInBorder(3, true);
  }

  /// Clears a border level and returns the line level at which it was cleared.
  ///
  /// The border level is cleared in the area defined by the [innerWidth] property
  /// and is centred within this area.
  ///
  /// Parameters:
  /// - `level`: The border level to clear.
  /// - `top`: Whether to clear the top (`true`) or bottom (`false`) border.
  ///
  /// Returns: The line level at which the border was cleared.
  int _clearInBorder(int level, bool top) {
    int y = top? level : terminal.height - (level - 1);
    
    terminal
    ..moveCursor(
      borderWidth + 1,
      y
    )
    ..print(
      Ansi.construct(border[level]!) + ' ' * (innerWidth - (2 * level)),
      newLine: false
    );

    return y;
  }

  /// Prints a [Line] in the border at the specified level and y offset.
  ///
  /// The [Line] is printed in the area defined by the [innerWidth] property
  /// and is centred within this area.
  ///
  /// Parameters:
  /// - `message`: The line to print.
  /// - `level`: The border level to print at.
  /// - `top`: Whether to print at the top (`true`) or bottom (`false`) of the
  ///   border.
  void _printInBorder(Line message, int level, bool top) {
    int y =_clearInBorder(level, top);

    terminal
      ..moveCursor(
        border.length * printItem.length,
        y 
      ) 
      ..print(
        message.render(),
        effects: Settings.borderForegroundEffects[level]! + border[level]!,
        newLine: false
      );
  }
}

