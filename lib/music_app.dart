import 'package:music_app/screen.dart';
import 'package:music_app/menu.dart';
import 'package:music_app/play_manager.dart';

/// A class to manage the music application.
///
/// This class holds all the music app's components such as the screen and the menu.
///
/// The application is started by calling [startUp].
///
/// The class provides methods to list options (songs) and to start the menu.
class MusicApp {
  static final Screen screen = Screen();
  final playManager = PlayManager(screen);
  final Menu menu = Menu(
    screen.terminal.width,
    screen.terminal.height,
    screen,
  );

  final int defaultNumberOfItemsToShow;
  final String? defaultTitle;
  final int defaultTitleSpace;
  final int defaultIndentOnItems;
  final int defaultExtraIndentOnSelected;
  final bool defaultEndListenerOnSelection;
  final int defaultDefaultIndex;

  MusicApp({
    this.defaultNumberOfItemsToShow = 5,
    this.defaultTitle,
    this.defaultTitleSpace = 1,
    this.defaultIndentOnItems = 0,
    this.defaultExtraIndentOnSelected = 0,
    this.defaultEndListenerOnSelection = true,
    this.defaultDefaultIndex = 0,
  }) {
    menu.playManager = playManager;
  }

  
  /// A wrapper function for [Menu.listOptions].
  ///
  /// This function wraps [Menu.listOptions] and provides default values for the parameters.
  ///
  /// The default values are:
  /// - `numberOfItemsToShow`: [defaultNumberOfItemsToShow]
  /// - `title`: [defaultTitle]
  /// - `titleSpace`: [defaultTitleSpace]
  /// - `indentOnItems`: [defaultIndentOnItems]
  /// - `extraIndentOnSelected`: [defaultExtraIndentOnSelected]
  /// - `endListenerOnSelection`: [defaultEndListenerOnSelection]
  /// - `defaultIndex`: [defaultDefaultIndex]
  void listOptions(
    Map<String, Function> options,
    {
      int? numberOfItemsToShow,
      String? title,
      int? titleSpace,
      int? indentOnItems,
      int? extraIndentOnSelected,
      bool? endListenerOnSelection,
      int? defaultIndex,
    }) {
      screen.showDebug('options listing...');
      
      menu.listOptions(
        options,
        numberOfItemsToShow: numberOfItemsToShow ?? defaultNumberOfItemsToShow,
        title: title ?? defaultTitle,
        titleSpace: titleSpace ?? defaultTitleSpace,
        indentOnItems: indentOnItems ?? defaultIndentOnItems,
        extraIndentOnSelected: extraIndentOnSelected ?? defaultExtraIndentOnSelected,
        endListenerOnSelection: endListenerOnSelection ?? defaultEndListenerOnSelection,
        defaultIndex: defaultIndex ?? defaultDefaultIndex,
      );

      screen.showDebug('options now visible');
    }
}