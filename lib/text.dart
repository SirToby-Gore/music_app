import 'dart:math';
import 'dart:io';

class Text {
  List<String> lines = [];
  
  int left;
  int right;
  int top;
  int bottom;

  int maxLineLength;
  int maxHeight;

  bool showEllipses;
  bool lineWrap;

  Text(
    dynamic text,
    this.maxLineLength,
    this.maxHeight,
    {
      this.left = 0,
      this.right = 0,
      this.top = 0,
      this.bottom = 0,
      this.lineWrap = false,
      this.showEllipses = true
    }
  ) {
    if (text.runtimeType == String) {
      text = text.split('\n');
    } else if (text.runtimeType != List<String>) {
      print('Input type of ${text.runtimeType} detected, input type must be of type String or List<String>');
      exit(1);
    }

    for (String line in text) {
      if (renderLine(line).length > maxLineLength) {
        int lineLength = maxLineLength - (left + right);

        if (lineWrap) {
          for (int i = 0; i < (line.length / lineLength).ceil(); i++) {
            lines.add(
              renderLine(
                line.substring(
                  lineLength * i,
                  min(
                    lineLength * (i + 1),
                    line.length
                  )
                )
              )
            );
          }

          continue;
        }

        line = line.substring(0, lineLength);

        if (showEllipses) {
          line = '${line.substring(0, line.length-3)}...';
        }
        
        lines.add(
          renderLine(
            line
          )
        );

        continue;
      } 

      lines.add(renderLine(line));
    }

    addTopLines();
    addBottomLines();

    flushLines();
  } 

  void addTopLines() {
    lines.insertAll(0, List.generate(top, (_) => ''));
  }

  void addBottomLines() {
    lines.addAll(List.generate(bottom, (_) => ''));
  }

  void flushLines() {
    bool overLimit = lines.length > maxHeight;
    
    while (lines.length > maxHeight) {
      lines.removeLast();  
    }
    if (showEllipses && overLimit) {
      lines.add('...');
    }
  }

  String renderLine(String line) {
    return line.padLeft(line.length + left).padRight(line.length + left + right);
  }
}

class CenterText extends Text {
  CenterText(super.text, super.maxLineLength, super.maxHeight);

  @override
  void addTopLines() {
    int numberOfLinesToAdd = ((maxHeight - lines.length)).toInt();

    lines.insertAll(0, List.generate(numberOfLinesToAdd, (_) => ''));
  }

  @override
  void addBottomLines() {
    lines.addAll(List.generate(maxHeight - lines.length, (_) => ''));
  }
  
  @override
  String renderLine(String line) {
    String sidePadding = ' ' * ((maxLineLength - line.length) ~/ 2); 
    return '$sidePadding$line$sidePadding';
  }
}
