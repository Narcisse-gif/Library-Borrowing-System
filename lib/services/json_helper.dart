import 'dart:convert';

class JsonHelper {
  static dynamic decode(String jsonString) {
    return jsonDecode(jsonString);
  }
}
