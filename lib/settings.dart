import 'package:rich_stdout/rich_stdout.dart';
/// This class contains all the settings for the application.
///
/// [titleAndExitScreenDuration] is the duration for which the title and exit screens are displayed.
///
/// [borderBackgroundEffects] is a map of border levels to their corresponding background effects. The keys are the border levels, and the values are lists of background effects to use for that level.
///
/// [borderPrintItem] is the character used to print the border. It is repeated to fill the width of the screen.
///
/// [borderForegroundEffects] is a map of border levels to their corresponding foreground effects. The keys are the border levels, and the values are lists of foreground effects to use for that level.
///
/// [welcomeText] is a list of strings representing the text to display on the welcome screen.
///
/// [exitText] is a list of strings representing the text to display on the exit screen.
class Settings {
  static Duration titleAndExitScreenDuration = const Duration(seconds: 1);

  static Map<int, List<int>> borderBackgroundEffects = {
    1: [
      Colour.backgroundPurple
    ],
    2: [
      Colour.backgroundBlue
    ],
    3: [
      Colour.backgroundLightBlue
    ],
  };

  static String borderPrintItem = '  ';

  static Map<int, List<int>> borderForegroundEffects = {
    1: [
      Colour.foregroundBlack
    ],

    2: [
      Colour.foregroundWhite
    ],
    
    3: [
      Colour.foregroundRed
    ],
  };

  static List<String> welcomeText = [
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

  static List<String> exitText = [
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
}
