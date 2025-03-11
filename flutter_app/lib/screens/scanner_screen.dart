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
  int _progressPercentage = 0;

  final Map<String, Color> vulnerabilityColors = {
    "sql_injection": Colors.redAccent,
    "xss": Colors.orangeAccent,
    "csrf": Colors.purpleAccent,
    "open_redirect": Colors.greenAccent,
    "security_headers": Colors.blueAccent,
    "command_injection": Colors.deepOrange,
    "file_inclusion": Colors.teal,
    "weak_passwords": Colors.brown,
  };

  Future<void> scanUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid URL")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = "";
      _results = {};
      _downloadLink = null;
      _progress = 0.0;
      _progressPercentage = 0;
    });

    try {
      // Simulate progress based on scan steps
      // Assume we have some stages in the scan process
      final scanStages = [
        "Connecting to server",
        "Scanning SQL Injection",
        "Scanning XSS",
        "Scanning CSRF",
        "Finalizing scan"
      ];

      for (int i = 0; i < scanStages.length; i++) {
        await Future.delayed(
            const Duration(seconds: 2)); // Simulating time for each stage

        // Update progress
        setState(() {
          _progress = (i + 1) / scanStages.length;
          _progressPercentage = ((_progress) * 100).toInt();
        });

        if (i == scanStages.length - 1) {
          // Mock successful response once the scanning is done
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
        }
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
          const SnackBar(content: Text("Could not open download link")),
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
            style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple)),
        backgroundColor: const Color.fromARGB(255, 128, 135, 239),
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TextField for URL input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter Website URL",
                prefixIcon: const Icon(Icons.link, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progress,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 40),
                      Text("Scanning: $_progressPercentage%",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: scanUrl,
              icon: const Icon(Icons.search),
              label: const Text("Scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
              ),
            ),
            const SizedBox(height: 20),
            // Common Vulnerabilities List
            ExpansionTile(
              title: Text("🛡️ Common Web Vulnerabilities",
                  style: GoogleFonts.poppins(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              children: [
                vulnerabilityTile("🚨 SQL Injection (SQLi)",
                    "Hackers insert malicious SQL queries into input fields to access or manipulate the database."),
                vulnerabilityTile("⚠️ Cross-Site Scripting (XSS)",
                    "Attackers inject malicious JavaScript into web pages to steal cookies, session tokens, or redirect users."),
                vulnerabilityTile("🔄 Cross-Site Request Forgery (CSRF)",
                    "Hackers trick users into performing unwanted actions, such as changing passwords or making transactions."),
                vulnerabilityTile("📂 File Inclusion Vulnerabilities",
                    "Attackers include malicious files to execute arbitrary code on the server."),
                vulnerabilityTile("🛑 Weak Security Headers",
                    "Poor HTTP headers allow attackers to intercept and manipulate web requests."),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _results.entries.map((entry) {
                  final color = vulnerabilityColors[entry.key] ?? Colors.grey;
                  return Card(
                    child: ListTile(
                      tileColor: color.withOpacity(0.1),
                      leading: CircleAvatar(
                          backgroundColor: color,
                          child: Icon(Icons.security, color: Colors.white)),
                      title: Text(entry.key.toUpperCase(),
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.value.toString()),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_downloadLink != null)
              ElevatedButton.icon(
                onPressed: _downloadReport,
                icon: const Icon(Icons.download),
                label: const Text("Download Report"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget vulnerabilityTile(String title, String description) {
    return ListTile(
      title:
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }
}
