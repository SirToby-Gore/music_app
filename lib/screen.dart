import 'package:music_app/text.dart';
import 'package:rich_stdout/rich_stdout.dart';
import 'package:music_app/mp3.dart';
import 'package:music_app/settings.dart';
import 'dart:math';
import 'dart:io';

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
  }

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

  /// this was vibe coded, know idea how it works, it just does
  void spiralTraverseAndApply<T>(
      List<List<T>> matrix,
      Function(T item, int row, int col) callback
    ) {
      if (matrix.isEmpty || matrix[0].isEmpty) {
        // Handle empty matrix or empty rows gracefully
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

  void showPlaying([MP3? song]) {
    currentSong = song;
  }

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

  void _startShowPlaying() async {
    while (true) {
      _showPlayState();

      await Future.delayed(const Duration(seconds: 1));
    }
  }

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

  /// clears the border in level and return the line level to do it at
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

