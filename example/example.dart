import 'dart:convert';
import 'dart:core';

import 'package:byter/byter.dart';

void main() {
    var byter=Byter('hello-world'.codeUnits);
    print(byter);
    byter.byte();
    byter.byte();
    print(byter);
    byter.eat(Byter('He'.codeUnits));

    print(utf8.decode(byter.toList()));
}
