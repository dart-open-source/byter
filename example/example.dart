import 'dart:convert';

import 'package:byter/byter.dart';

Future<void> main() async {

  var byter=Byter('hello-world'.codeUnits);
  print(byter);
  byter.byte();
  byter.byte();
  print(byter);
  byter.eat(Byter('He'.codeUnits));

  print(utf8.decode(byter.all));

}
