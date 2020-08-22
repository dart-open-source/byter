import 'package:convert/convert.dart';

///
/// About:->
/// Copyright 2020 Alm.Pazel
/// License-Identifier: MIT
///
///

class Byter {
  final List<int> _bytes = [];

  List<int> get all => _bytes;

  int get first => _bytes.first;

  void clear() => _bytes.clear();

  @override
  String toString() => 'Byter{${length}}';

  String toHexString() => hex.encode(all);

  Byter([dynamic input]) {
    _bytes.clear();
    if (input is List<int>) _bytes.addAll(input);
    if (input is String) _bytes.addAll(hex.decode(input));
  }

  int get length => _bytes.length;

  bool get isEmpty => _bytes.isEmpty;

  bool get isNotEmpty => _bytes.isNotEmpty;

  Byter bytes([int len = 1]) {
    var r = _bytes.sublist(0, len);
    _bytes.removeRange(0, len);
    return Byter(r);
  }

  int byte() {
    int b;
    try {
      b = bytes(1)?.first;
    } catch (e) {
      b = null;
    }
    return b;
  }

  void add(dynamic b) {
    if (b is int) _bytes.add(b);
    if (b is Byter) addAll(b.all);
  }

  void addAll(List<int> os) => os.forEach(add);

  void eat(dynamic b) {
    if (b is int) _bytes.insert(0, b);
    if (b is Byter) eatAll(b.all);
  }

  void eatAll(List<int> os) => os.reversed.forEach(eat);

  Byter clone() => Byter(all);

  int toInt({int radix = 16}) => int.parse(toHexString(), radix: radix);
}
