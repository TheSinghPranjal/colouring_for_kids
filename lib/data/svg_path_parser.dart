import 'dart:ui';

/// Parses SVG path data (`d` attribute) into a Flutter [Path].
///
/// Supports M, L, H, V, C, S, Q, T and Z in absolute and relative form, which
/// covers everything the template generator emits plus common hand-edited
/// paths. Arc commands are rejected so bad geometry fails loudly in tests.
Path parseSvgPathData(String data, {PathFillType fillType = PathFillType.evenOdd}) {
  final path = Path()..fillType = fillType;
  final tokens = _tokenize(data);
  var i = 0;
  String? command;
  var current = Offset.zero;
  var subpathStart = Offset.zero;
  Offset? lastControl;

  double next() {
    if (i >= tokens.length || tokens[i] is! double) {
      throw FormatException('Expected a number in path data at token $i');
    }
    return tokens[i++] as double;
  }

  while (i < tokens.length) {
    final token = tokens[i];
    if (token is String) {
      command = token;
      i++;
    } else if (command == null) {
      throw const FormatException('Path data must start with a command');
    }
    final c = command;
    final relative = c.toLowerCase() == c;
    Offset pt(double x, double y) => relative ? current + Offset(x, y) : Offset(x, y);

    switch (c.toUpperCase()) {
      case 'M':
        current = pt(next(), next());
        subpathStart = current;
        path.moveTo(current.dx, current.dy);
        // Subsequent pairs after a moveto are implicit linetos.
        command = relative ? 'l' : 'L';
        lastControl = null;
      case 'L':
        current = pt(next(), next());
        path.lineTo(current.dx, current.dy);
        lastControl = null;
      case 'H':
        final x = next();
        current = Offset(relative ? current.dx + x : x, current.dy);
        path.lineTo(current.dx, current.dy);
        lastControl = null;
      case 'V':
        final y = next();
        current = Offset(current.dx, relative ? current.dy + y : y);
        path.lineTo(current.dx, current.dy);
        lastControl = null;
      case 'C':
        final c1 = pt(next(), next());
        final c2 = pt(next(), next());
        final end = pt(next(), next());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastControl = c2;
        current = end;
      case 'S':
        final c1 = lastControl == null ? current : current * 2 - lastControl;
        final c2 = pt(next(), next());
        final end = pt(next(), next());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastControl = c2;
        current = end;
      case 'Q':
        final c1 = pt(next(), next());
        final end = pt(next(), next());
        path.quadraticBezierTo(c1.dx, c1.dy, end.dx, end.dy);
        lastControl = c1;
        current = end;
      case 'T':
        final c1 = lastControl == null ? current : current * 2 - lastControl;
        final end = pt(next(), next());
        path.quadraticBezierTo(c1.dx, c1.dy, end.dx, end.dy);
        lastControl = c1;
        current = end;
      case 'Z':
        path.close();
        current = subpathStart;
        lastControl = null;
        command = null;
      default:
        throw FormatException('Unsupported path command "$c"');
    }
  }
  return path;
}

final RegExp _tokenPattern = RegExp(r'[MmLlHhVvCcSsQqTtZzAa]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');

List<Object> _tokenize(String data) => [
  for (final m in _tokenPattern.allMatches(data))
    if (RegExp(r'^[A-Za-z]$').hasMatch(m.group(0)!)) m.group(0)! else double.parse(m.group(0)!),
];
