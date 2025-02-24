import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _urlController = TextEditingController();
  Map<String, dynamic> _results = {};
  String _error = "";
  bool _isLoading = false;
  String? _downloadLink;
  double _progress = 0.0;

  Future<void> scanUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid URL")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = "";
      _results = {};
      _downloadLink = null;
      _progress = 0.0;
    });

    try {
      for (double i = 0.0; i <= 1.0; i += 0.2) {
        await Future.delayed(Duration(milliseconds: 500));
        setState(() => _progress = i);
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/scan"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"url": url}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _results = data["results"];
          _downloadLink = "http://127.0.0.1:5000" + data["download_link"];
        });
      } else {
        setState(() => _error = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _error = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    if (_downloadLink != null) {
      final Uri url = Uri.parse(_downloadLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open download link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Vulnerability Scanner",
            style:
                GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade200,
              Colors.blue.shade300,
              Colors.green.shade200
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade400, blurRadius: 6),
                  ],
                ),
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: "Enter URL",
                    labelStyle: GoogleFonts.poppins(
                        color: Colors.blueAccent, fontSize: 18),
                    prefixIcon:
                        Icon(Icons.link, color: Colors.blueAccent, size: 28),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: scanUrl,
                icon: Icon(Icons.search, size: 28),
                label: Text("Scan", style: GoogleFonts.poppins(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 25),
              _isLoading
                  ? Column(
                      children: [
                        SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(
                              value: _progress,
                              color: Colors.green,
                              minHeight: 10),
                        ),
                        SizedBox(height: 25),
                        Text("Scanning... ${(100 * _progress).toInt()}%",
                            style: GoogleFonts.poppins(fontSize: 22)),
                      ],
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: _results.entries.map((entry) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                title: Text(entry.key.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent)),
                                subtitle: Text(entry.value.toString(),
                                    style: GoogleFonts.poppins(fontSize: 18)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
              if (_downloadLink != null) SizedBox(height: 25),
              if (_downloadLink != null)
                ElevatedButton.icon(
                  onPressed: _downloadReport,
                  icon: Icon(Icons.download, size: 28),
                  label: Text("Download Report",
                      style: GoogleFonts.poppins(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
