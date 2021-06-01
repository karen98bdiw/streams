import 'package:http/http.dart' as http;

class FetchService {
  FetchService._internal();
  static final FetchService fetchService = FetchService._internal();
  String base = "http://numbersapi.com/";

  factory FetchService() => fetchService;

  http.Client _client = http.Client();

  Future<String> fetch(int number) async {
    try {
      var res = await _client.get("$base$number");
      if (res.statusCode == 200) return res.body;

      return null;
    } catch (e) {
      print("error in fetch request with $e");
      return null;
    }
  }
}
