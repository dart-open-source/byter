A Byter library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://gitee.com/almpazel/dart-byter/blob/master/LICENSE).

## Usage

This package used to byte data, in flutter also work.

## Tested
- byte;
- eat;eatAl;
- add;addAl;
- toHexString;
- toString;
- if you need other contact with Email.

A simple usage example:

```dart
import 'package:byter/byter.dart';

main() {
  //Change your printer ip

  var byter=Byter('hello-world'.codeUnits);
  print(byter);
  byter.byte();
  byter.byte();
  print(byter);
  byter.eat(Byter('He'.codeUnits));

  print(utf8.decode(byter.all));
  
}
```

## References

....