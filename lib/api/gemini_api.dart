import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, String>> getHeader() async {
 return {
   'Content-Type': 'application/json',
 };
}

Future<String> getGeminiData(String message, String budgetRange,
   String attractionType, String month) async {
 try {
   String apiKey = 'AIzaSyBvz43BIB2L2l1eNlCHhfJCDyprR94LSd4';
   final header = await getHeader();

   List<String> range = budgetRange.split(' to ');
   int minBudget = int.parse(range[0]);
   int maxBudget = int.parse(range[1]);

   String budgetCategory;
   if (maxBudget <= 5000) {
     budgetCategory = "low";
   } else if (maxBudget <= 15000) {
     budgetCategory = "medium";
   } else {
     budgetCategory = "high";
   }

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

[Examples 3-10 remain the same...]

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

Destination: [3. Name of alternative recommended destination]
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

   String url =
       'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey';
   
   var response = await http.post(
     Uri.parse(url),
     headers: header,
     body: jsonEncode(requestBody),
   );

   if (response.statusCode == 503) {
     int maxRetries = 3;
     int currentTry = 0;
     
     while (currentTry < maxRetries) {
       await Future.delayed(Duration(seconds: 2 * (currentTry + 1)));
       response = await http.post(
         Uri.parse(url),
         headers: header,
         body: jsonEncode(requestBody),
       );
       
       if (response.statusCode == 200) {
         break;
       }
       currentTry++;
     }
     
     if (response.statusCode == 503) {
       return 'Service temporarily unavailable. Please try again later.';
     }
   }

   if (response.statusCode == 200) {
     try {
       var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
       String rawOutput =
           jsonResponse['candidates'][0]['content']['parts'][0]['text'];
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
 print("Raw output from API: $rawOutput");

 RegExp regex = RegExp(
     r'Destination: (.+)[\n\r]+Nearby restaurants:[\n\r]+((?:- .+[\n\r]?)+)',
     multiLine: true);
 Match? match = regex.firstMatch(rawOutput);

 if (match != null) {
   String destination = match.group(1)?.trim() ?? '';
   String restaurants = match.group(2)?.trim() ?? '';
   return 'Destination: $destination\nNearby restaurants:\n$restaurants';
 } else {
   return 'API Response:\n$rawOutput';
 }
}