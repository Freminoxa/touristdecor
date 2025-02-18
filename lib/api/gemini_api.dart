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
- Carnivore Restaurant (Famous for its all-you-can-eat meat feast and lively atmosphere)
- Ranger's Restaurant (Offers panoramic views of the park and serves delicious local cuisine)

2. Budget: medium, Category: Beaches
Destination: Diani Beach
Nearby restaurants:
- Sails Beach Bar & Restaurant (Beachfront dining with fresh seafood and stunning ocean views)
- Ali Barbour's Cave Restaurant (Unique dining experience in a coral cave with romantic ambiance)

3. Budget: high, Category: Mountains
Destination: Mount Kenya National Park
Nearby restaurants:
- Serena Mountain Lodge Restaurant (Offers breathtaking views of Mount Kenya and serves gourmet international cuisine)
- Fairmont Mount Kenya Safari Club (Luxurious dining with farm-to-table ingredients and a view of the mountain)

4. Budget: low, Category: Cultural Sites
Destination: Bomas of Kenya
Nearby restaurants:
- Utamu Restaurant (Serves authentic Kenyan dishes in a vibrant, cultural setting)
- Nyama Choma Ranch (Famous for its traditional Kenyan barbecue and lively atmosphere)

5. Budget: medium, Category: Snake Parks
Destination: Mamba Village Centre, Mombasa
Nearby restaurants:
- Tamarind Mombasa (Elegant seafood restaurant with a terrace overlooking the creek)
- Forodhani Restaurant (Offers a mix of Swahili and international cuisine with a relaxed ambiance)

6. Budget: high, Category: Wildlife
Destination: Ol Pajeta Conservancy
Nearby restaurants:
- Morani's Restaurant (Offers farm-to-table dining with ingredients from the conservancy's own garden)
- Serena Sweetwaters Tented Camp Restaurant (Provides a unique dining experience with views of a watering hole frequented by wildlife)

7. Budget: medium, Category: Lakes
Destination: Lake Nakuru National Park
Nearby restaurants:
- Sarova Lion Hill Game Lodge Restaurant (Offers panoramic views of the lake and serves a mix of local and international cuisine)
- Lake Nakuru Lodge Restaurant (Known for its bush breakfasts and dinners with stunning lake views)

8. Budget: low, Category: Historical Sites
Destination: Fort Jesus, Mombasa
Nearby restaurants:
- Jahazi Coffee House (Charming café serving local coffee and light meals in a historic setting)
- Forodhani Restaurant (Offers traditional Swahili dishes with a view of the old town)

9. Budget: high, Category: Marine Parks
Destination: Watamu Marine National Park
Nearby restaurants:
- Medina Palms Ocean Spa (Luxurious beachfront dining with a focus on fresh, locally-sourced seafood)
- Pilli Pipa Dhow Restaurant (Unique dining experience on a traditional dhow, serving freshly caught fish)

10. Budget: medium, Category: Wildlife
Destination: Amboseli National Park
Nearby restaurants:
- Kibo Safari Camp Restaurant (Offers al fresco dining with views of Mount Kilimanjaro)
- Ol Tukai Lodge Restaurant (Serves international cuisine with a Kenyan twist and offers elephant watching during meals)
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
  //  print the raw output for debugging
  print("Raw output from API: $rawOutput");

  //  extracting destination and restaurants
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