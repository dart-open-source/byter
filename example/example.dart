import 'dart:convert';

import 'package:byter/byter.dart';

Future<void> main() async {

  var byter=Byter('hello-world'.codeUnits);
  print(byter);

  byter.byte();
  byter.byte();

  print(byter);

  byter.nyte();
  byter.nyte();

  print(byter);

  print(byter.str());

}
