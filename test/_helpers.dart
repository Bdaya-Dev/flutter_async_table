import 'dart:math';
import 'dart:convert';

String getRandString(int len) {
  var random = Random(654321);
  var values = List<int>.generate(len, (i) =>  random.nextInt(255));
  return base64UrlEncode(values);
}