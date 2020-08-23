import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';

///
/// About:->
/// Copyright 2020 Alm.Pazel
/// License-Identifier: MIT
///
///

class Byter {
  List<int> _bytes = [];

  List<int> get all => _bytes;

  int get first => _bytes.first;

  int get last => _bytes.last;
  int _bytePos = 0;

  void clear() => _bytes.clear();

  @override
  String toString() => 'Byter{${length} ${all.sublist(0,min(length,10)).toString().replaceAll(']', length>10?'...]':']')} }';

  String toHexString([int len]) => hex.encode(len==null?all:all.sublist(0,len));

  Byter([dynamic input]) {
    _bytes.clear();
    if (input is String) input = hex.decode(input);
    if (input is List<int>) {
      _bytes.addAll(input);
    }
  }

  int get length => _bytes.length - _bytePos;

  bool get isEmpty => length <= 0;

  bool get isNotEmpty => length > 0;

  Byter bytes([int len = 1]) {
    var l=<int>[];
    for (var i = 0; i < len; i++) {
      l.add(byte());
    }
    return Byter(l);
  }

  int byte() {
    int b;
    try {
      b = _bytes[_bytePos++];
    } catch (e) {
      b = null;
    }
    return b;
  }

  int nyte() {
    _bytePos--;
  }

  void add(dynamic b) {
    if (b is int) _bytes.add(b);
    if (b is Byter) addAll(b.all);
  }
  void addAll(List<int> os) => os.forEach(add);
//
//  void eat(dynamic b) {
//    if (b is int) _bytes.insert(0, b);
//    if (b is Byter) eatAll(b.all);
//  }
//
//  void eatAll(List<int> os) => os.reversed.forEach(eat);

  Byter clone({bool reset = false}) {
    var n = Byter(all);
    if (reset) clear();
    return n;
  }

  int toInt({int radix = 16}) => int.parse(toHexString(), radix: radix);

  String str({bool trim=true}) {
    var r=StringBuffer();
    all.forEach(r.writeCharCode);
    return r.toString();
  }
}
