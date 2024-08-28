import 'package:flutter/material.dart';

import 'package:geminiapi/api/gemini_api.dart';



class TouristAttractionPage extends StatefulWidget {
  const TouristAttractionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TouristAttractionPageState createState() => _TouristAttractionPageState();
}

class _TouristAttractionPageState extends State<TouristAttractionPage> {
  String _selectedBudgetRange = '0 to 5000';
  final List<String> _attractions = ['Wildlife', 'Beaches', 'Mountains', 'National Parks', 'Museums','National Reserves', 'Snake Parks'];
  final List<String> _selectedAttractions = [];
  String _selectedMonth = 'January';
  String _result = '';

  @override

  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Tourist Attractions'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wildlife2.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Content with transparent background
          SingleChildScrollView(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Budget Slider
                  // Budget Dropdown
            Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Your Budget Range',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      DropdownButton<String>(
        dropdownColor: Colors.grey,
        value: _selectedBudgetRange,
        items: <String>[
          '0 to 5000',
          '5000 to 15000',
          '15000 to 30000'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedBudgetRange = newValue!;
          });
        },
      ),
    ],
  ),
),
                  // Attraction Types
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Type of Attraction',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Wrap(
                          spacing: 10.0,
                          children: _attractions.map((attraction) {
                            return FilterChip(
                              label: Text(attraction),
                              selected: _selectedAttractions.contains(attraction),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAttractions.add(attraction);
                                  } else {
                                    _selectedAttractions.remove(attraction);
                                  }
                                });
                              },
                              selectedColor: Colors.blue,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Month Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Month to Visit',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        DropdownButton<String>(
                          dropdownColor: Colors.grey,
                          value: _selectedMonth,
                          items: <String>[
                            'January', 'February', 'March', 'April', 'May', 'June',
                            'July', 'August', 'September', 'October', 'November', 'December'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMonth = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Search Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
  String attractionType = _selectedAttractions.isNotEmpty ? _selectedAttractions.join(', ') : 'Specific';
  String result = await getGeminiData('Find attractions', _selectedBudgetRange, attractionType, _selectedMonth.toString());
  setState(() {
    _result = result;
  });
},
                      child: const Text('Find Attractions'),
                    ),
                  ),
                  // Result Display
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _result,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
