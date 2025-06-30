import 'package:rich_stdout/rich_stdout.dart';

class Text {
  String text;
  int length = 0;

  Text(this.text, {int whitespaceLeft = 0, int whitespaceRight = 0}) {
    text = '${' ' * whitespaceLeft}$text';
    text = '$text${' ' * whitespaceRight}';

    length = text.length;
  }
}

class Style extends Text {
  Style(List<int> styles) : super(Ansi.construct(styles)) {
    length = 0;
  }
}

class ResetStyle extends Style {
  ResetStyle() : super([Effect.reset]);
}

class Line {
  List<Text> line;
  int length = 0;
  int maxLength;
  int whitespaceLeft;
  int whitespaceRight;
  String beginningString; // New optional argument
  String endingString; // New optional argument

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

  int _getLengthTotal() {
    int sum = whitespaceLeft + whitespaceRight;

    line.toList().forEach(
      (line) {
        sum += line.length;
      },
    );

    return sum;
  }

  String render() {
    String renderedLineContent = line.map(
      (line) => line.text,
    ).join();

    // Apply internal whitespace
    renderedLineContent =
        '${' ' * whitespaceLeft}$renderedLineContent${' ' * whitespaceRight}';

    // Add beginning and ending strings
    return '$beginningString$renderedLineContent$endingString';
  }
}

class CenterLine extends Line {
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

class MaxLineRight extends Line {
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

class MaxLineLeft extends Line {
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

class Paragraph {
  List<Line> lines;
  int maxHeight;
  int length = 0;

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
            whitespaceTop, (_) => Line([Text('')], lines.first.maxLength)),
        ...lines,
        ...List.generate(
            whitespaceBottom, (_) => Line([Text('')], lines.first.maxLength)),
      ];
    }

    length = lines.length;
  }
}

class CenterParagraph extends Paragraph {
  CenterParagraph(super.lines, super.maxHeight)
      : super(
            whitespaceTop: (maxHeight - lines.length) ~/ 2,
            whitespaceBottom: (maxHeight - lines.length) ~/ 2);
}