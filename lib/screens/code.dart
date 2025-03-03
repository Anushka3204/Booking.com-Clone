import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ItineraryScreen extends StatefulWidget {
  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _daysController =
      TextEditingController(); // New controller for number of days
  bool _isLoading = false;
  String _itinerary = "";

  Future<void> _generateItinerary() async {
    if (_destinationController.text.isEmpty || _daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please enter both destination and number of days.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _itinerary = "";
    });

    final String apiKey =
        "AIzaSyA65jID9tl_QCZywK08LBfWjjSvvcWCBX0"; // Replace with your actual API key
    final Uri apiUrl = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey");

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Plan a detailed ${_daysController.text}-day itinerary for a trip to ${_destinationController.text}. Preferences: ${_preferencesController.text}. Include sightseeing, food recommendations, and travel tips."
            }
          ]
        }
      ]
    };

    try {
      final response = await http
          .post(
            apiUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 15));

      // Log the entire response body for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Log the parsed response for debugging
        print('Parsed Response Data: $data');

        // Check if the response contains the 'candidates' key
        if (data.containsKey('candidates')) {
          var candidates = data['candidates'];
          if (candidates is List && candidates.isNotEmpty) {
            var content = candidates[0]['content'];
            if (content != null && content['parts'] is List) {
              var parts = content['parts'];
              if (parts.isNotEmpty) {
                setState(() {
                  _itinerary = parts[0]['text'] ?? "No itinerary generated.";
                  _isLoading = false;
                });
              } else {
                setState(() {
                  _itinerary = "No parts found in response.";
                  _isLoading = false;
                });
              }
            } else {
              setState(() {
                _itinerary = "No content parts found in response.";
                _isLoading = false;
              });
            }
          } else {
            setState(() {
              _itinerary = "No candidates found in response.";
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _itinerary =
                "Response does not contain 'candidates'. Please check the response format.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _itinerary =
              "Failed to generate itinerary. Status Code: ${response.statusCode}.";
          _isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        _itinerary = "Request timed out. Please try again later.";
        _isLoading = false;
      });
      print("Request timed out");
    } catch (e) {
      setState(() {
        _itinerary = "An error occurred: $e";
        _isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Itinerary Planner"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: "Enter Destination",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _preferencesController,
              decoration: InputDecoration(
                labelText:
                    "Preferences (e.g., adventure, food, budget-friendly)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Number of Days",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _generateItinerary, // Disable when loading
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Generate Itinerary"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _itinerary.isEmpty
                  ? Center(
                      child: Text("Enter details and generate an itinerary"))
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[100], // Light blue background
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _itinerary,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
