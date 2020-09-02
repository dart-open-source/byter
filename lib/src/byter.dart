import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:collection/collection.dart';
import 'bits.dart';

///
/// About:->
/// Copyright 2020 Alm.Pazel
/// License-Identifier: MIT
///
///

class Byter {
  int offset = 0;
  final int start = 0;
  List<int> buffer = [];

  int get size => buffer.length;

  bool bigEndian;

  ///  The current read position relative to the start of the buffer.
  int get position => offset - start;

  /// How many bytes are left in the stream.
  int get length => size - offset;

  /// Is the current position at the end of the stream?
  bool get isEOS => offset >= size;

  int get first => buffer[offset];
  bool get isEmpty => buffer.isEmpty;
  bool get isNotEmpty => buffer.isNotEmpty;

  /// Reset to the beginning of the stream.
  void rewind() {
    offset = start;
  }

  /// Access the buffer relative from the current position.
  int operator [](int index) => buffer[offset + index];

  /// Set a buffer element relative to the current position.
  operator []=(int index, int value) => buffer[offset + index] = value;

  void clear() => buffer.clear();

  /// Copy data from [other] to this buffer, at [start] offset from the
  /// current read position, and [length] number of bytes. [offset] is
  /// the offset in [other] to start reading.
  void memcpy(int start, int length, dynamic other, [int offset = 0]) {
    if (other is Byter) {
      buffer.setRange(this.offset + start, this.offset + start + length, other.buffer, other.offset + offset);
    } else {
      buffer.setRange(this.offset + start, this.offset + start + length, other as List<int>, offset);
    }
  }

  /// Set a range of bytes in this buffer to [value], at [start] offset from the
  ///current read position, and [length] number of bytes.
  void memset(int start, int length, int value) {
    buffer.fillRange(offset + start, offset + start + length, value);
  }

  /// Return a Byter to read of this stream.
  Byter bytes(int count) {
    var list = <int>[];
    var i = 0;
    while (i < count) {
      list.add(byte());
      i++;
    }
    return Byter(list);
  }

  /// Returns the position of the given [value] within the buffer, starting
  /// from the current read position with the given [offset]. The position
  /// returned is relative to the start of the buffer, or -1 if the [value]
  /// was not found.
  int indexOf(int value, [int offset = 0]) {
    for (var i = this.offset + offset, end = this.offset + length; i < end; ++i) {
      if (buffer[i] == value) {
        return i - start;
      }
    }
    return -1;
  }

  @override
  String toString() => 'Byter{ length:${length} offset:${offset} start:${start} end:${size} }';

  String toHexString([int length]) => hex.encode(toList(length));

  /// Create a InputStream for reading from a List<int>
  Byter(List<int> buffer, {this.bigEndian = false}) {
    this.buffer.clear();
    this.buffer.addAll(buffer);
    this.offset = offset;
  }

  /// Read a single byte.
  int byte() {
    int b;
    try {
      b = buffer[offset++];
    } catch (e) {
      b = null;
    }
    return b;
  }

  /// Move the read position by back one byte.
  void nyte() {
    offset--;
  }

  /// Move the read position by [count] bytes.
  void skip(int count) {
    offset += count;
  }

  Byter clone({bool reset = false}) {
    var n = Byter(toList());
    if (reset) clear();
    return n;
  }

  int toInt({int radix = 16}) => int.parse(toHexString(2), radix: radix);

  String str({bool trim = true}) {
    var r = StringBuffer();
    buffer.forEach(r.writeCharCode);
    return r.toString();
  }

  List<int> toList([int length]) {
    return buffer.sublist(offset, length != null ? length + offset : size);
  }

  int readInt8() {
    return uint8ToInt8(byte());
  }

  /// Read [count] bytes from the stream.
  Byter readBytes(int count) {
    var bytesd = bytes(count);
    offset += bytesd.length;
    return bytesd;
  }

  /// Read a null-terminated string, or if [len] is provided, that number of
  /// bytes returned as a string.
  String readString([int len]) {
    if (len == null) {
      var codes = <int>[];
      while (!isEOS) {
        var c = byte();
        if (c == 0) {
          return String.fromCharCodes(codes);
        }
        codes.add(c);
      }
      throw Exception('EOF reached without finding string terminator');
    }

    var s = readBytes(len);
    var bytes = s.toUint8List();
    var str = String.fromCharCodes(bytes);
    return str;
  }

  /// Read a 16-bit word from the stream.
  int readUint16() {
    var b1 = buffer[offset++] & 0xff;
    var b2 = buffer[offset++] & 0xff;
    if (bigEndian) {
      return (b1 << 8) | b2;
    }
    return (b2 << 8) | b1;
  }

  /// Read a 16-bit word from the stream.
  int readInt16() {
    return uint16ToInt16(readUint16());
  }

  /// Read a 24-bit word from the stream.
  int readUint24() {
    var b1 = buffer[offset++] & 0xff;
    var b2 = buffer[offset++] & 0xff;
    var b3 = buffer[offset++] & 0xff;
    if (bigEndian) {
      return b3 | (b2 << 8) | (b1 << 16);
    }
    return b1 | (b2 << 8) | (b3 << 16);
  }

  /// Read a 32-bit word from the stream.
  int readUint32() {
    var b1 = buffer[offset++] & 0xff;
    var b2 = buffer[offset++] & 0xff;
    var b3 = buffer[offset++] & 0xff;
    var b4 = buffer[offset++] & 0xff;
    if (bigEndian) {
      return (b1 << 24) | (b2 << 16) | (b3 << 8) | b4;
    }
    return (b4 << 24) | (b3 << 16) | (b2 << 8) | b1;
  }

  /// Read a signed 32-bit integer from the stream.
  int readInt32() {
    return uint32ToInt32(readUint32());
  }

  /// Read a 32-bit float.
  double readFloat32() {
    return uint32ToFloat32(readUint32());
  }

  /// Read a 64-bit float.
  double readFloat64() {
    return uint64ToFloat64(readUint64());
  }

  /// Read a 64-bit word form the stream.
  int readUint64() {
    var b1 = buffer[offset++] & 0xff;
    var b2 = buffer[offset++] & 0xff;
    var b3 = buffer[offset++] & 0xff;
    var b4 = buffer[offset++] & 0xff;
    var b5 = buffer[offset++] & 0xff;
    var b6 = buffer[offset++] & 0xff;
    var b7 = buffer[offset++] & 0xff;
    var b8 = buffer[offset++] & 0xff;
    if (bigEndian) {
      return (b1 << 56) | (b2 << 48) | (b3 << 40) | (b4 << 32) | (b5 << 24) | (b6 << 16) | (b7 << 8) | b8;
    }
    return (b8 << 56) | (b7 << 48) | (b6 << 40) | (b5 << 32) | (b4 << 24) | (b3 << 16) | (b2 << 8) | b1;
  }

  Uint8List toUint8List([int offset = 0, int length]) {
    var len = length ?? this.length - offset;
    if (buffer is Uint8List) {
      var b = buffer as Uint8List;
      return Uint8List.view(b.buffer, b.offsetInBytes + this.offset + offset, len);
    }
    return (buffer is Uint8List) ? (buffer as Uint8List).sublist(this.offset + offset, this.offset + offset + len) : Uint8List.fromList(buffer.sublist(this.offset + offset, this.offset + offset + len));
  }

  Uint32List toUint32List([int offset = 0]) {
    if (buffer is Uint8List) {
      var b = buffer as Uint8List;
      return Uint32List.view(b.buffer, b.offsetInBytes + this.offset + offset);
    }
    return Uint32List.view(toUint8List().buffer);
  }

  void add(dynamic b) {
    if (b is int) buffer.add(b);

    if (b is Byter) addAll(b.buffer);
  }

  void addAll(List<int> os) => os.forEach(add);

  void eat(dynamic b) {
    if (b is int) buffer.insert(0, b);
    if (b is Byter) eatAll(b.buffer);
  }

  void eatAll(List<int> os) => os.reversed.forEach(eat);

  Function eq = const ListEquality().equals;

  bool isContains(String s) {
    var sl = s.codeUnits.length;
    if (sl <= length) {
      var temp = buffer.sublist(offset, sl);
      return eq(temp, s.codeUnits);
    }
    return false;
  }
}
