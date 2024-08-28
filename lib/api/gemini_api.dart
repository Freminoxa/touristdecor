import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, String>> getHeader() async {
  return {
    'Content-Type': 'application/json',
  };
}

Future<String> getGeminiData(String message, String budgetRange, String attractionType, String month) async {
  try {
    String apiKey = 'AIzaSyA7TEBy1_pZ2WvXrFPUop20w3HHWitsShg';
    final header = await getHeader();

    // Parse the budget range
    List<String> range = budgetRange.split(' to ');
    int minBudget = int.parse(range[0]);
    int maxBudget = int.parse(range[1]);

    // Determine budget category based on the range
    String budgetCategory;
    if (maxBudget <= 5000) {
      budgetCategory = "low";
    } else if (maxBudget <= 15000) {
      budgetCategory = "medium";
    } else {
      budgetCategory = "high";
    }

    // Expanded few-shot examples for Kenya
    String fewShotExamples = '''
Example outputs for Kenya tourism:
1. Budget: low, Category: Wildlife
Destination: Nairobi National Park
Nearby restaurants:
- Carnivore Restaurant
- Ranger's Restaurant
2. Budget: medium, Category: Beaches
Destination: Diani Beach
Nearby restaurants:
- Sails Beach Bar & Restaurant
- Ali Barbour's Cave Restaurant
3. Budget: high, Category: Mountains
Destination: Mount Kenya National Park
Nearby restaurants:
- Serena Mountain Lodge Restaurant
- Fairmont Mount Kenya Safari Club
4. Budget: low, Category: Cultural Sites
Destination: Bomas of Kenya
Nearby restaurants:
- Utamu Restaurant
- Nyama Choma Ranch
5. Budget: medium, Category: Snake Parks
Destination: Mamba Village Centre, Mombasa
Nearby restaurants:
- Tamarind Mombasa
- Forodhani Restaurant

Please provide a recommendation for Kenya tourism based on the following criteria:
Budget: $budgetCategory (Range: $minBudget to $maxBudget)
Category: $attractionType
Month of visit: $month

Your response should include:
Destination: [1. Name of the recommended destination]
Nearby restaurants:
- [Restaurant 1]
- [Restaurant 2]
- [Restaurant 3]

Destination: [2. Name of alternative recommended destination]
- [Restaurant 1]
- [Restaurant 2]
- [Restaurant 3]





Please ensure your response follows this exact format.
''';
    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': fewShotExamples + message,
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 700,
        'topP': 1.0,
        'topK': 40,
      }
    };

    String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey';
    var response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        String rawOutput = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return processOutput(rawOutput);
      } on FormatException {
        return 'Error: Failed to decode JSON response.';
      }
    } else if (response.statusCode == 400) {
      return 'Error: Bad Request';
    } else {
      return 'Error: ${response.statusCode}';
    }
  } on SocketException {
    return 'No internet connection';
  } catch (e) {
    print("Error: $e");
    return 'Unexpected error occurred. Please try again later.';
  }
}

String processOutput(String rawOutput) {
  // First, let's print the raw output for debugging
  print("Raw output from API: $rawOutput");

  // Try to extract destination and restaurants
  RegExp regex = RegExp(r'Destination: (.+)[\n\r]+Nearby restaurants:[\n\r]+((?:- .+[\n\r]?)+)', multiLine: true);
  Match? match = regex.firstMatch(rawOutput);

  if (match != null) {
    String destination = match.group(1)?.trim() ?? '';
    String restaurants = match.group(2)?.trim() ?? '';
    return 'Destination: $destination\nNearby restaurants:\n$restaurants';
  } else {
    // If the expected format isn't found, return the raw output
    return 'API Response:\n$rawOutput';
  }
}