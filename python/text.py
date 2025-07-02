import 'package:rich_stdout/rich_stdout.dart';
/// A class representing a single line of text
class Text {
  /// The text to be displayed
  String text;

  /// The length of the text
  int length = 0;

  /// Create a new Text object
  ///
  /// [whitespaceLeft] and [whitespaceRight] are optional and default to 0
  Text(this.text, {int whitespaceLeft = 0, int whitespaceRight = 0}) {
    text = '${' ' * whitespaceLeft}$text';
    text = '$text${' ' * whitespaceRight}';

    length = text.length;
  }
}

/// A class that wraps a [Text] object and applies styles to it
class Style extends Text {
  /// Create a new Style object
  ///
  /// [styles] is a list of [Effect]s to be applied to the text
  Style(List<int> styles) : super(Ansi.construct(styles)) {
    length = 0;
  }
}

/// A class that resets the text style
class ResetStyle extends Style {
  ResetStyle() : super([Effect.reset]);
}

/// A class representing a line of text
class Line {
  /// The list of [Text] objects that make up the line
  List<Text> line;

  /// The length of the line
  int length = 0;

  /// The maximum length of the line
  int maxLength;

  /// The amount of whitespace to the left of the line
  int whitespaceLeft;

  /// The amount of whitespace to the right of the line
  int whitespaceRight;

  /// The string to be rendered at the beginning of the line
  String beginningString; // New optional argument

  /// The string to be rendered at the end of the line
  String endingString; // New optional argument

  /// Create a new Line object
  ///
  /// [maxLength] is the maximum length of the line
  ///
  /// [whitespaceLeft] and [whitespaceRight] are optional and default to 0
  ///
  /// [beginningString] and [endingString] are optional and default to empty strings
  Line(
    this.line,
    this.maxLength, {
    this.whitespaceLeft = 0,
    this.whitespaceRight = 0,
    this.beginningString = '', // Default to empty string
    this.endingString = '', // Default to empty string
  }) {
    // Adjust maxLength to account for beginning and ending strings
    int effectiveMaxLength = maxLength - beginningString.length - endingString.length;

    if (_getLengthTotal() > effectiveMaxLength) {
      print('Length of line is too large');
      // Consider throwing an error or truncating if it exceeds maxLength
    }

    length = _getLengthTotal() + beginningString.length + endingString.length;
  }

  /// Get the total length of the line
  int _getLengthTotal() {
    int sum = whitespaceLeft + whitespaceRight;

    line.toList().forEach(
      (line) {
        sum += line.length;
      },
    );

    return sum;
  }

  /// Render the line as a string
  String render() {
    String renderedLineContent = line.map(
      (line) => line.text,
    ).join();

    // Apply internal whitespace
    renderedLineContent =
        '${' ' * whitespaceLeft}$renderedLineContent${' ' * whitespaceRight}';

    return '$beginningString$renderedLineContent$endingString';
  }
}

/// A class that centers a line of text
class CenterLine extends Line {
  /// Create a new CenterLine object
  ///
  /// [maxLength] is the maximum length of the line
  ///
  /// [whitespaceLeft] and [whitespaceRight] are optional and default to 0
  ///
  /// [beginningString] and [endingString] are optional and default to empty strings
  CenterLine(
    List<Text> line,
    int maxLength, {
    String beginningString = '',
    String endingString = '',
  }) : super(
          line,
          maxLength,
          whitespaceLeft: 0,
          whitespaceRight: 0,
          beginningString: beginningString,
          endingString: endingString,
        ) {
    int effectiveMaxLength = maxLength - beginningString.length - endingString.length;
    int diff = effectiveMaxLength - _getLengthTotal();

    whitespaceLeft = diff ~/ 2;
    whitespaceRight = diff - whitespaceLeft; // Ensure total diff is covered

    if (_getLengthTotal() > effectiveMaxLength) {
      print('Length of line is too large');
      throw Error();
    }

    // Update the total length after recalculating whitespace
    length = _getLengthTotal() + beginningString.length + endingString.length;
  }
}

/// A class that aligns a line of text to the right
class MaxLineRight extends Line {
  /// Create a new MaxLineRight object
  ///
  /// [maxLength] is the maximum length of the line
  ///
  /// [whitespaceLeft] and [whitespaceRight] are optional and default to 0
  ///
  /// [beginningString] and [endingString] are optional and default to empty strings
  MaxLineRight(
    List<Text> line,
    int maxLength, {
    String beginningString = '',
    String endingString = '',
  }) : super(
          line,
          maxLength,
          whitespaceLeft: 0,
          whitespaceRight: maxLength -
              line.map((e) => e.length).reduce((a, b) => a + b) -
              beginningString.length -
              endingString.length,
          beginningString: beginningString,
          endingString: endingString,
        ) {
    if (_getLengthTotal() > maxLength - beginningString.length - endingString.length) {
      print('Length of line is too large');
      throw Error();
    }
    // Update the total length after recalculating whitespace
    length = _getLengthTotal() + beginningString.length + endingString.length;
  }
}

/// A class that aligns a line of text to the left
class MaxLineLeft extends Line {
  /// Create a new MaxLineLeft object
  ///
  /// [maxLength] is the maximum length of the line
  ///
  /// [whitespaceLeft] and [whitespaceRight] are optional and default to 0
  ///
  /// [beginningString] and [endingString] are optional and default to empty strings
  MaxLineLeft(
    List<Text> line,
    int maxLength, {
    String beginningString = '',
    String endingString = '',
  }) : super(
          line,
          maxLength,
          whitespaceLeft: maxLength -
              line.map((e) => e.length).reduce((a, b) => a + b) -
              beginningString.length -
              endingString.length,
          whitespaceRight: 0,
          beginningString: beginningString,
          endingString: endingString,
        ) {
    if (_getLengthTotal() > maxLength - beginningString.length - endingString.length) {
      print('Length of line is too large');
      throw Error();
    }
    // Update the total length after recalculating whitespace
    length = _getLengthTotal() + beginningString.length + endingString.length;
  }
}

/// A class representing a paragraph of text
class Paragraph {
  /// The list of [Line] objects that make up the paragraph
  List<Line> lines;

  /// The maximum height of the paragraph
  int maxHeight;

  /// The length of the paragraph
  int length = 0;

  /// Create a new Paragraph object
  ///
  /// [maxHeight] is the maximum height of the paragraph
  ///
  /// [whitespaceTop] and [whitespaceBottom] are optional and default to 0
  Paragraph(this.lines, this.maxHeight,
      {int whitespaceTop = 0, int whitespaceBottom = 0}) {
    if (lines.isEmpty) {
      // Handle empty lines list
      if ((whitespaceTop + whitespaceBottom) > maxHeight) {
        print('Too many whitespace lines for empty paragraph');
        throw Error();
      }
      lines = List.generate(whitespaceTop + whitespaceBottom, (_) => Line([Text('')], 0)); // Create empty lines
    } else {
      if ((lines.length + whitespaceTop + whitespaceBottom) > maxHeight) {
        print('Too many lines');
        throw Error();
      }

      lines = [
        ...List.generate(
          whitespaceTop, (_) => CenterLine([Text('')], lines.first.maxLength)
        ),
        ...lines,
        ...List.generate(
          whitespaceBottom, (_) => CenterLine([Text('')], lines.first.maxLength)
        ),
      ];
    }

    length = lines.length;
  }
}

/// A class that centers a paragraph of text
class CenterParagraph extends Paragraph {
  /// Create a new CenterParagraph object
  ///
  /// [maxHeight] is the maximum height of the paragraph
  CenterParagraph(super.lines, super.maxHeight)
  : super(
    whitespaceTop: (maxHeight - lines.length) ~/ 2,
    whitespaceBottom: (maxHeight - lines.length) ~/ 2
  );
}
