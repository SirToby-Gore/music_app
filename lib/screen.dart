import 'package:music_app/text.dart';
import 'package:rich_stdout/rich_stdout.dart';
import 'package:music_app/mp3.dart';
import 'dart:math';
import 'dart:io';

class Screen {
  final Terminal terminal = Terminal();
  final String resetStyle = Ansi.construct([Effect.reset]);
  final String printItem = '  ';
  List<List<String>> screen = [];
  MP3? currentSong;
  
  List<String> border = [
    Ansi.construct([Colour.backgroundPurple]),
    Ansi.construct([Colour.backgroundBlue]),
    Ansi.construct([Colour.backgroundLightBlue])
  ];
  
  int innerSpace = 0;

  Screen() {
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
            || rowNumber == height - (borderPointer+1)
            || columnNumber == borderPointer
            || columnNumber == printWidth - (borderPointer+1)
          ) {
            row.add('${border[borderPointer]}$printItem$resetStyle');
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

    List<String> titleScreenRaw = [
      '.------------------------------------------------------------.',
      '|                                                            |',
      '|  ___      ___  ____  ____    ________    __       ______   |',
      '| |"  \\    /"  |("  _||_ " |  /"       )  |" \\     /" _  "\\  |',
      '|  \\   \\  //   ||   (  ) : | (:   \\___/   ||  |   (: ( \\___) |',
      '|  /\\\\  \\/.    |(:  |  | . )  \\___  \\     |:  |    \\/ \\      |',
      '| |: \\.        | \\\\ \\__/ //    __/  \\\\    |.  |    //  \\ _   |',
      '| |.  \\    /:  | /\\\\ __ //\\   /" \\   :)   /\\  |\\  (:   _) \\  |',
      '| |___|\\__/|___|(__________) (_______/   (__\\_|_)  \\_______) |',
      '|                                                            |',
      '|       __         _______      _______                      |',
      '|      /""\\       |   __ "\\    |   __ "\\                     |',
      '|     /    \\      (. |__) :)   (. |__) :)                    |',
      '|    /\' /\\  \\     |:  ____/    |:  ____/                     |',
      '|   //  __\'  \\    (|  /        (|  /                         |',
      '|  /   /  \\\\  \\  /|__/ \\      /|__/ \\                        |',
      '| (___/    \\___)(_______)    (_______)                       |',
      '|                                                            |',
      '\'------------------------------------------------------------\'',
    ];

    drawBorder();
    
    int innerWidth = width - (border.length * 2 * printItem.length);
    int innerHeight = height - (border.length * 2 * printItem.length);

    Text titleScreenText = CenterText(
      titleScreenRaw,
      innerWidth,
      innerHeight,
    );

    writeTextFromCorner(titleScreenText);

    sleep(Duration(seconds: 2));
  }

  void drawBorder({MP3? song, String? title, int startDelay = 6}) async {
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

  void writeTextFromCorner(Text text) {
    int width = terminal.width - (border.length * printItem.length * 2);
    
    List<List<String>> screen = List.generate(
      terminal.height - (border.length * printItem.length * 2),
      (_) => List.generate(
        width,
        (_) => ' '
      )
    );

    for (var i = 0; i < text.lines.length; i++) {
      String line = text.lines[i];
      
      for (var ii = 0; ii < line.length; ii++) {
        screen[i][ii] = line[ii];
      }
    }
    
    for (int linePointer = 0; linePointer < screen.length; linePointer++) {
      terminal.moveCursor(
        (printItem.length * border.length) + 1,
        border.length + linePointer + 1
      );

      String line = screen[linePointer].join();
      
      terminal.print(line, newLine: false);
    }

    terminal.moveCursor(terminal.width, terminal.height);
  }

  void showCommands(List<String> commands) {
    _printInBorder(
      Text(
        commands.join(' ' * 5)
        ,
        terminal.width - 2,
        1,
        showEllipses: true,
        lineWrap: false
      ),
      1,
      false
    );
  }

  void showPlaying([MP3? song]) {
    currentSong = song;
  }

  void _showPlayState() async {
    const int lenOfPlayBar = 15;
    
    _printInBorder(
      Text(
        (
          currentSong != null ? [
            [
              currentSong!.metaData.title ?? '',
              '-',
              currentSong!.metaData.artist ?? '',
            ].join(' '),
            [
              currentSong!.playing ? '' : Ansi.construct([Effect.slowBlink]),
              '[',
              List.generate(
                lenOfPlayBar,
                (i) => (currentSong!.elapsedEstimate * lenOfPlayBar / currentSong!.metaData.duration!.inSeconds) >= i ? '#' : ' '
              ).join(),
              ']',
              currentSong!.playing ? '' : Ansi.construct([Effect.blinkOff])
            ].join()
          ].join('  ')
          : '<no song playing>'
        ),
        terminal.width - 2,
        1,
        showEllipses: true,
        lineWrap: false
      ),
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
      Text(
        [
          'space: play/pause',
          'n: next',
          'r: restart song',
        ].join(' ' * 5),
        terminal.width - printItem.length * 2,
        1,
      ),
      2,
      false
    );
  }

  void showTitle(String title) {
    _printInBorder(
      Text(
        Ansi.construct([Effect.bold, Effect.underlined]) + title,
        terminal.width - (printItem.length * 2),
        1
      ),
      2,
      true
    );
  }

  void showErrorMessage(String message, [int displayTime = 5]) async {
    _printInBorder(
      Text(
        message,
        terminal.width - (border.length * 2 * printItem.length),
        1
      ),
      3,
      true
    );

    await Future.delayed(Duration(seconds: displayTime));

    _printInBorder(
      Text(
        '',
        terminal.width - (border.length * 2 * printItem.length),
        1
      ),
      3,
      true
    );
  }

  void _printInBorder(Text message, int level, bool top) {
    int y = top? level : terminal.height - level + 1;
    
    terminal
      ..moveCursor(
        (level * printItem.length * 2) + 1,
        y
      )
      ..print(
        border[level - 1] + ' ' * (terminal.width - (printItem.length * 2 * (level + 1))),
        newLine: false
      )
      ..moveCursor(
        (terminal.width ~/ 2) - (message.lines.first.length ~/ 2),
        y
      ) 
      ..print(
        border[level - 1] + message.lines.first,
        effects: [
          {
            1: Colour.foregroundBlack,
            2: Colour.foregroundWhite,
            3: Colour.foregroundRed,
          }[level]!
        ],
        newLine: false
      );
  }
}

