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
  final TextEditingController _daysController = TextEditingController();
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
                  "Imagine you are an expert travel agent with years of experience crafting the most exciting and personalized trips. Your task is to design a detailed ${_daysController.text}-day itinerary for an unforgettable journey to ${_destinationController.text}, perfectly tailored to the traveler's preferences: ${_preferencesController.text}. This itinerary should blend a mix of iconic landmarks, breathtaking natural wonders, and hidden local gems that most tourists overlook. Provide carefully curated recommendations for sightseeing, thrilling activities, cultural experiences, and must-try local dishes, ensuring a rich and immersive travel experience. Offer helpful travel tips, including the best times to visit each location, transportation options, and budget-friendly hacks. Keep the tone lively, engaging, and playful, making the traveler feel as if they have a knowledgeable yet fun-loving guide by their side. The itinerary should be structured yet flexible, allowing room for spontaneity and adventure. Make sure to strike the perfect balance between relaxation and exploration, ensuring an enriching yet enjoyable journey. Keep the details concise but vivid, painting a picture of the experience without overwhelming the traveler with excessive information. Your goal is to create an itinerary that sparks excitement, fuels wanderlust, and guarantees a memorable adventure. Let the planning begin! Give in format 💠 Day 1 : in bold ,the 🔶 Morning: ,🔶 Midday:,  Do not use * in response.Give some travel tips also after iternary like : 💠Travel tips(in bold) : 🔶  ...give 4-5 tipes ..leave a line after each"
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

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
    } catch (e) {
      setState(() {
        _itinerary = "An error occurred: $e";
        _isLoading = false;
      });
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
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange), // Orange border
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _preferencesController,
              decoration: InputDecoration(
                labelText:
                    "Preferences (e.g., adventure, food, budget-friendly)",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange), // Orange border
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Number of Days",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange), // Orange border
                ),
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
                          color: Colors.blue[50],
                          border:
                              Border.all(color: Colors.blue[900]!, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            children: _getFormattedItinerary(_itinerary),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _getFormattedItinerary(String itinerary) {
    List<TextSpan> spans = [];
    RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    Iterable<Match> matches = boldRegex.allMatches(itinerary);

    int lastEnd = 0;
    for (Match match in matches) {
      // Add text before the bold part
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: itinerary.substring(lastEnd, match.start)));
      }
      // Add the bold part
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    // Add any remaining text after the last bold part
    if (lastEnd < itinerary.length) {
      spans.add(TextSpan(text: itinerary.substring(lastEnd)));
    }

    return spans;
  }
}
