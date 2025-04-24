import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // ← added

class MovieMoodScreen extends StatefulWidget {
  @override
  _MovieMoodScreenState createState() => _MovieMoodScreenState();
}

class _MovieMoodScreenState extends State<MovieMoodScreen> {
  final TextEditingController _movieController = TextEditingController();
  String? _formattedResponse;
  String? _posterUrl;

  // ← added
  Future<void> _launchURL(String query) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _getMoodBasedTravel() async {
    final movie = _movieController.text.trim();
    if (movie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a movie name")),
      );
      return;
    }

    final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyA65jID9tl_QCZywK08LBfWjjSvvcWCBX0");
    final headers = {"Content-Type": "application/json"};
    final prompt = """
Based on the movie "$movie", suggest 2 to 3 travel destinations that reflect its mood, setting, or overall vibe.

For each destination, first list the subplaces or specific locations you would recommend visiting (in bullet points).

Then, give a description related to the movie's atmosphere, scene, or characters below the destination name. The description should capture the essence of the movie's vibe and why this destination is relevant.

Example format:

<Destination Name>
💠 Subplace 1
💠 Subplace 2
💠 Subplace 3
Description of the destination related to the movie's characters and scene.

Please choose destinations that either appear in the movie or closely resemble the scenery, emotions, or adventure shown in it.

Avoid using asterisks (), quotes, or markdown formatting. Keep the tone imaginative but concise.
""";
    final body = json.encode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawText =
            data["candidates"][0]["content"]["parts"][0]["text"] as String;
        final posterUrl = await _getPoster(movie);
        setState(() {
          _formattedResponse = rawText.trim();
          _posterUrl = posterUrl;
        });
      } else {
        throw Exception("Failed to get response: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<String?> _getPoster(String movie) async {
    final posterUri =
        Uri.parse("http://www.omdbapi.com/?t=$movie&apikey=b60f587e");
    try {
      final posterResponse = await http.get(posterUri);
      if (posterResponse.statusCode == 200) {
        final posterData = json.decode(posterResponse.body);
        if (posterData['Poster'] != 'N/A') {
          return posterData['Poster'];
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          "Movie Mood Travel",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let your favorite film choose your next trip !",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 14, 74, 143),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _movieController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Enter Movie Name",
                labelStyle: TextStyle(color: Colors.blue[800]),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _getMoodBasedTravel,
              child: Text("Find Destination"),
            ),
            SizedBox(height: 24),
            if (_posterUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _posterUrl!,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (_formattedResponse != null)
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue[900]!, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _formattedResponse!
                        .split('\n')
                        .fold<List<Widget>>([], (acc, line) {
                      final text = line.trim();
                      if (text.isEmpty) return acc;

                      // Destination heading
                      if (text.split(' ').length <= 3 &&
                          RegExp(r'^[A-Z]').hasMatch(text)) {
                        acc.add(
                          GestureDetector(
                            onTap: () => _launchURL(text),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ),
                        );
                        // Double blue lines
                        acc.addAll([
                          Divider(color: Colors.blue[900], thickness: 2),
                          Divider(color: Colors.blue[900], thickness: 2),
                        ]);
                      }
                      // Subplace
                      else if (text.startsWith("-")) {
                        final place = text.substring(1).trim();
                        acc.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "💠 $place",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                      // Description
                      else {
                        acc.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 12),
                            child: Text(
                              text,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4),
                            ),
                          ),
                        );
                      }
                      return acc;
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
