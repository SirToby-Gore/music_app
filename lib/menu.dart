import 'package:rich_stdout/rich_stdout.dart';
import 'package:music_app/screen.dart';
import 'package:music_app/text.dart';
import 'package:music_app/globals.dart' as globals;
import 'package:music_app/play_manager.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

enum Character {
  newLine,
  escape,
  space,
  
  exclamation,
  doubleQuote,
  hash,
  dollarSign,
  percentSign,
  ampersand,
  singleQuote,
  openBracket,
  closeBracket,
  star,
  plus,
  comma,
  hyphen,
  fullStop,
  forwardSlash,

  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,

  colon,
  semicolon,
  lessThan,
  equals,
  greaterThan,
  questionMark,
  at,

  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
  L,
  M,
  N,
  O,
  P,
  Q,
  R,
  S,
  T,
  U,
  V,
  W,
  X,
  Y,
  Z,

  openSquare,
  backslash,
  closeSquare,
  caret,
  underscore,
  backtick,
  
  a,
  b,
  c,
  d,
  e,
  f,
  g,
  h,
  i,
  j,
  k,
  l,
  m,
  n,
  o,
  p,
  q,
  r,
  s,
  t,
  u,
  v,
  w,
  x,
  y,
  z,

  openBrace,
  verticalPipe,
  closeBrace,
  tilde,
  poundSign,
  
  home,
  end,
  insert,
  backspace,
  pageUp,
  pageDown,

  upArrow,
  downArrow,
  rightArrow,
  leftArrow,

  unknown,
}

class Menu {
  int width;
  int height;
  bool debug;
  Screen screen;
  StreamSubscription<List<int>>? subscription;
  PlayManager? playManager;

  final List<int> _currentlySelected = [0];
  final List<Map<String, Function>> _options = [{}];
  final List<int> _numberOfItemsToShow = [5];
  final List<String?> _title = [null];
  final List<int> _titleSpace = [1];
  final List<int> _indentOnItems = [0];
  final List<int> _extraIndentOnSelected = [0];
  final List<bool> _endListenerOnSelection = [true];

  Menu(this.width, this.height, this.screen, {this.debug = false}) {
    if (globals.menu) {
      screen.terminal.error('Menu object already initialised');
      throw Error();
    } else {
      globals.menu = true;
    }

    if (stdin.hasTerminal) {
      stdin.lineMode = false;
      stdin.echoMode = false;
    } else {
      screen.terminal.error('Application requires an interactive terminal.');
      exit(1);
    }
    
    subscription = stdin.listen((List<int> data) {
      Character character = getCharFromCode(data);

      if (debug) {
        screen.writeTextFromCorner(Text('$data: $character', screen.terminal.width, screen.terminal.height));
        sleep(Duration(milliseconds: 500));
      }

      // handle user input
      switch (character) {
        case Character.newLine:
          _options.last[_options.last.keys.elementAt(_currentlySelected.last)]!();
        
        case Character.downArrow:
          if (_currentlySelected.last < _options.last.length - 1) {
            _currentlySelected.last++;
          }
          break;
        
        case Character.leftArrow:
          if (_currentlySelected.last > 0) {
            _currentlySelected.last--;
            break;
          } else {
            _currentlySelected.last = _options.last.length - 1;
            break;
          }
        
        case Character.upArrow:
          if (_currentlySelected.last > 0) {
            _currentlySelected.last--;
          }
          break;
        
        case Character.rightArrow:
          if (_currentlySelected.last < _options.last.length - 1) {
            _currentlySelected.last++;
            break;
          } else {
            _currentlySelected.last = 0;
            break;
          }
        
        case Character.pageUp:
          _currentlySelected.last = max(_currentlySelected.last - _numberOfItemsToShow.last + 1, 0);
          break;
        
        case Character.pageDown:
          _currentlySelected.last = min(_currentlySelected.last + _numberOfItemsToShow.last - 1, _options.last.length - 1);
          break;
        
        case Character.home:
          _currentlySelected.last = 0;
          break;
        
        case Character.end:
          _currentlySelected.last = _options.last.length -1;
        break;

        case Character.backspace || Character.escape:
          if (
            _currentlySelected.length > 2
            && _options.length > 2
            && _numberOfItemsToShow.length > 2
            && _title.length > 2
            && _titleSpace.length > 2
            && _indentOnItems.length > 2
            && _extraIndentOnSelected.length > 2
            && _endListenerOnSelection.length > 2
          ) {
            _currentlySelected.removeLast();
            _options.removeLast();
            _numberOfItemsToShow.removeLast();
            _title.removeLast();
            _titleSpace.removeLast();
            _indentOnItems.removeLast();
            _extraIndentOnSelected.removeLast();
            _endListenerOnSelection.removeLast();

            showCurrentMenu();

            screen.drawBorder(
              song: playManager?.currentSong,
              startDelay: 0,
              title: _title.last ?? ''
            );
          }
          
          break;
        
        case Character.space:
          if (playManager?.currentSong == null) {
            break;
          }

          if (playManager!.currentSong!.playing) {
            playManager!.currentSong!.pause();
          } else {
            playManager!.currentSong!.resume();
          }

          screen.showPlaying(playManager!.currentSong);

          break;
        
        case Character.n:
          if (playManager?.playQueue == null) {
            break;
          }

          if (playManager!.playQueue.length > 1) {
            playManager?.currentSong?.stop();
            // playManager!.playQueue.removeAt(0);
            playManager!.startPlayQueue();
          }

          break;
        
        case Character.r:
          playManager?.currentSong?.restart();
          screen.showPlaying(playManager?.currentSong);
          break;
          
        default:
          break;
      }

      showCurrentMenu();
    }); 
  }

  void listOptions(
    Map<String, Function> options,
    {
      int numberOfItemsToShow = 5,
      String? title,
      int titleSpace = 1,
      int indentOnItems = 0,
      int extraIndentOnSelected = 0,
      bool endListenerOnSelection = true,
      int defaultIndex = 0,
    }) {
    _currentlySelected.add(min(numberOfItemsToShow, defaultIndex));
    _options.add(options);
    _numberOfItemsToShow.add(numberOfItemsToShow);
    _title.add(title);
    _titleSpace.add(titleSpace);
    _indentOnItems.add(indentOnItems);
    _extraIndentOnSelected.add(extraIndentOnSelected);
    _endListenerOnSelection.add(endListenerOnSelection);

    if (_title.last != null) {
      screen.showTitle(_title.last!);
    }

    showCurrentMenu();
  }

  void showCurrentMenu() {
    if (_numberOfItemsToShow.last.isEven) {
      print('number of items to show must be odd ${_numberOfItemsToShow.last} is even');
      exit(1);
    }
    
    int innerWidth = screen.terminal.width - (screen.border.length * 2 * screen.printItem.length);
    int innerHeight = screen.terminal.height - (screen.border.length * 2);

    if (_numberOfItemsToShow.last > innerHeight) {
      screen.terminal.error('number of items to show is too many, must be within the max number lines of $innerHeight');
    }

    int midWayItem = _numberOfItemsToShow.last ~/ 2;

    List<String> rows = List.generate(
      _numberOfItemsToShow.last,
      (index) => [
        screen.printItem * _indentOnItems.last,
        getAtIndexOrNull(
          _options.last.keys,
          index + _currentlySelected.last - midWayItem
        ) ?? ''
      ].join()
    );

    rows[midWayItem] = [
      screen.printItem * _indentOnItems.last,
      screen.printItem * _extraIndentOnSelected.last,
      [
        '>',
        Ansi.construct([Colour.backgroundWhite, Colour.foregroundBlack]),
        rows[midWayItem].trim(),
        Ansi.construct([Effect.reset])
      ].join(' ')
    ].join();

    if (_title.last != null) {
      rows.insert(
        0,
        [
          screen.printItem * _titleSpace.last,
          Ansi.construct([Effect.underlined, Effect.bold]),
          _title.last,
          Ansi.construct([Effect.reset]),
        ].join()
      );

      for (var i = 0; i < _titleSpace.last; i++) {
        rows
          ..insert(1, '')
          ..insert(0, '');
      }
    }
    
    screen.writeTextFromCorner(
      Text(
        rows,
        innerWidth,
        innerHeight,
      )
    );
  }

  String? getAtIndexOrNull(Iterable<String> list, int index){
    if (index > list.length - 1) {
      return null;
    }
    if (index < 0) {
      return null;
    }
    return list.elementAt(index);
  }

  Character getCharFromCode(List<int> data) {
    switch (data) {
      // control characters
      case [10]:
        return Character.newLine;
      case [27]:
        return Character.escape;
      case [32]:
        return Character.space;

      // punctuation
      case [33]:
        return Character.exclamation;
      case [34]:
        return Character.doubleQuote;
      case [35]:
        return Character.hash;
      case [36]:
        return Character.dollarSign;
      case [37]:
        return Character.percentSign;
      case [38]:
        return Character.ampersand;
      case [39]:
        return Character.singleQuote;
      case [40]:
        return Character.openBracket;
      case [41]:
        return Character.closeBracket;
      case [42]:
        return Character.star;
      case [43]:
        return Character.plus;
      case [44]:
        return Character.comma;
      case [45]:
        return Character.hyphen;
      case [46]:
        return Character.fullStop;
      case [47]:
        return Character.forwardSlash;
      
      // numbers
      case [48]:
        return Character.zero;
      case [49]:
        return Character.one;
      case [50]:
        return Character.two;
      case [51]:
        return Character.three;
      case [52]:
        return Character.four;
      case [53]:
        return Character.five;
      case [54]:
        return Character.six;
      case [55]:
        return Character.seven;
      case [56]:
        return Character.eight;
      case [57]:
        return Character.nine;

      // more punctuation
      case [58]:
        return Character.colon;
      case [59]:
        return Character.semicolon;
      case [60]:
        return Character.lessThan;
      case [61]:
        return Character.equals;
      case [62]:
        return Character.greaterThan;
      case [63]:
        return Character.questionMark;
      case [64]:
        return Character.at;

      // uppercase letters
      case [65]:
        return Character.A;
      case [66]:
        return Character.B;
      case [67]:
        return Character.C;
      case [68]:
        return Character.D;
      case [69]:
        return Character.E;
      case [70]:
        return Character.F;
      case [71]:
        return Character.G;
      case [72]:
        return Character.H;
      case [73]:
        return Character.I;
      case [74]:
        return Character.J;
      case [75]:
        return Character.K;
      case [76]:
        return Character.L;
      case [77]:
        return Character.M;
      case [78]:
        return Character.N;
      case [79]:
        return Character.O;
      case [80]:
        return Character.P;
      case [81]:
        return Character.Q;
      case [82]:
        return Character.R;
      case [83]:
        return Character.S;
      case [84]:
        return Character.T;
      case [85]:
        return Character.U;
      case [86]:
        return Character.V;
      case [87]:
        return Character.W;
      case [88]:
        return Character.X;
      case [89]:
        return Character.Y;
      case [90]:
        return Character.Z;

      case [91]:
        return Character.openSquare;
      case [92]:
        return Character.backslash;
      case [93]: 
        return Character.closeSquare;
      case [94]:
        return Character.caret;
      case [95]:
        return Character.underscore;
      case [96]:
        return Character.backtick;
      
      // lowercase
      case [97]:
        return Character.a;
      case [98]:
        return Character.b;
      case [99]:
        return Character.c;
      case [100]:
        return Character.d;
      case [101]:
        return Character.e;
      case [102]:
        return Character.f;
      case [103]:
        return Character.g;
      case [104]:
        return Character.h;
      case [105]:
        return Character.i;
      case [106]:
        return Character.j;
      case [107]:
        return Character.k;
      case [108]:
        return Character.l;
      case [109]:
        return Character.m;
      case [110]:
        return Character.n;
      case [111]:
        return Character.o;
      case [112]:
        return Character.p;
      case [113]:
        return Character.q;
      case [114]:
        return Character.r;
      case [115]:
        return Character.s;
      case [116]:
        return Character.t;
      case [117]:
        return Character.u;
      case [118]:
        return Character.v;
      case [119]:
        return Character.w;
      case [120]:
        return Character.x;
      case [121]:
        return Character.y;
      case [122]:
        return Character.z;
      
      case [123]:
        return Character.openBrace;
      case [124]:
        return Character.verticalPipe;
      case [125]:
        return Character.closeBrace;
      case [126]:
        return Character.tilde;
      case [194, 163]:
        return Character.poundSign;

      case [27, 91, 72]:
        return Character.home;
      case [27, 91, 70]:
        return Character.end;
      case [27, 91, 50, 126]:
        return Character.insert;
      case [127]:
        return Character.backspace;
      case [27, 91, 53, 126]:
        return Character.pageUp;
      case [27, 91, 54, 126]:
        return Character.pageDown;

      // arrow keys
      case [27, 91, 65]:
        return Character.upArrow;
      case [27, 91, 66]:
        return Character.downArrow;
      case [27, 91, 67]:
        return Character.rightArrow;
      case [27, 91, 68]:
        return Character.leftArrow;
        
      default:
        return Character.unknown;
    }
  }

// Make the function asynchronous
  void exitMenu() async {
    subscription?.cancel();
    subscription = null;

    try {
      final List<String> goodbyeLines = [
        '.----------------------------------------------------------------------------.',
        '|                                                                            |',
        '|   _______     ______      ______    ________   _______  ___  ___  _______  |',
        '|  /" _   "|   /    " \\    /    " \\  |"      "\\ |   _  "\\|"  \\/"  |/"     "| |',
        '| (: ( \\___)  // ____  \\  // ____  \\ (.  ___  :)(. |_)  :)\\   \\  /(: ______) |',
        '|  \\/ \\      /  /    ) :)/  /    ) :)|: \\   ) |||:     \\/  \\\\  \\/  \\/    |   |',
        '|  //  \\ ___(: (____/ //(: (____/ // (| (___\\ ||(|  _  \\\\  /   /   // ___)_  |',
        '| (:   _(  _|\\        /  \\        /  |:       :)|: |_)  :)/   /   (:      "| |',
        '|  \\_______)  \\"_____/    \\"_____/   (________/ (_______/|___/     \\_______) |',
        '|                                                                            |',
        '\'----------------------------------------------------------------------------\'',
      ];
      screen.writeTextFromCorner(Text(
        goodbyeLines,
        screen.terminal.width - (screen.border.length * 2 * screen.printItem.length),
        screen.terminal.height - (screen.border.length * 2)
      ));
    } catch (e) {
      print('Error reading goodbye.txt: $e');
      screen.writeTextFromCorner(Text(
        'Goodbye!',
        screen.terminal.width - (screen.border.length * 2 * screen.printItem.length),
        screen.terminal.height - (screen.border.length * 2)
      ));
    }

    await Future.delayed(Duration(seconds: 1));

    await playManager?.currentSong?.stop();

    screen.terminal
      ..clear()
      ..moveCursor(0, 0)
      ..endOfFile();

    if (stdin.hasTerminal) {
      try {
        stdin
          ..echoMode = true
          ..lineMode = true;
        if (debug) print('Terminal modes restored: echoMode=${stdin.echoMode}, lineMode=${stdin.lineMode}');
      } catch (e) {
        print('Error restoring terminal modes: $e');
      }
    } else {
      if (debug) print('Cannot restore terminal modes: stdin no longer has a terminal.');
    }
    
    exit(0);
  }
}

