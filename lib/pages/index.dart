import 'package:flutter/material.dart';
import 'package:geminiapi/api/gemini_api.dart';

class TouristAttractionPage extends StatefulWidget {
  const TouristAttractionPage({super.key});

  @override
  _TouristAttractionPageState createState() => _TouristAttractionPageState();
}

class _TouristAttractionPageState extends State<TouristAttractionPage> {
  String _selectedBudgetRange = '0 to 5000';
  final List<String> _attractions = ['Wildlife', 'Beaches', 'Mountains', 'National Parks', 'Museums', 'National Reserves', 'Snake Parks','Wildbeast','Big Five'];
  final List<String> _selectedAttractions = [];
  String _selectedMonth = 'January';
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Tourist Attractions'),
        backgroundColor: Colors.blue[800],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/tourist.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Content with transparent background
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Budget Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Select Your Budget Range',
                                  style: TextStyle(color: Colors.black, fontSize: 20),
                                ),
                                DropdownButton<String>(
                                  isExpanded: false,
                                  dropdownColor: Colors.blue,
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Choose Type of Attraction',
                                  style: TextStyle(color: Colors.black, fontSize: 20),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Select Month to Visit',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                                DropdownButton<String>(
                                  isExpanded: false,
                                  dropdownColor: Colors.blue,
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
                                setState(() {
                                  _isLoading = true; // Set loading state to true when button is pressed
                                });

                                String attractionType = _selectedAttractions.isNotEmpty ? _selectedAttractions.join(', ') : 'Specific';
                                String result = await getGeminiData('Find attractions', _selectedBudgetRange, attractionType, _selectedMonth.toString());
                                
                                setState(() {
                                  _result = result;
                                  _isLoading = false; // Set loading state to false once the data is fetched
                                });
                              },
                              child: const Text('Find Attractions'),
                            ),
                          ),
                          // Result Display in SafeArea Container
                          if (_result.isNotEmpty) // Only show if there's a result
                            SafeArea(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _result,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Show loading indicator if loading is true
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
