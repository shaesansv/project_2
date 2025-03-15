import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
      final scanStages = [
        "Connecting to server",
        "Scanning SQL Injection",
        "Scanning XSS",
        "Scanning CSRF",
        "Finalizing scan"
      ];

      for (int i = 0; i < scanStages.length; i++) {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _progress = (i + 1) / scanStages.length;
          _progressPercentage = ((_progress) * 100).toInt();
        });

        if (i == scanStages.length - 1) {
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
        title: Container(
          height: 500, // Increased height
          width: double.infinity, // Full width
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.blueAccent.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security,
                  color: Colors.white, size: 60), // Larger icon
              SizedBox(width: 12),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    "Vulnerability Scanner",
                    textStyle: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      Colors.white,
                      Colors.lightBlueAccent,
                      Colors.deepPurpleAccent,
                      Colors.blueAccent,
                    ],
                    speed: const Duration(milliseconds: 300),
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: "Enter Website URL",
                  prefixIcon: const Icon(Icons.link, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Column(
                      children: [
                        LinearProgressIndicator(
                            value: _progress, color: Colors.green),
                        const SizedBox(height: 40),
                        Text("Scanning: $_progressPercentage%",
                            style: GoogleFonts.poppins(
                                fontSize: 25, fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 28)),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🛡️ Common Web Vulnerabilities",
                    style: GoogleFonts.poppins(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    childAspectRatio: 2.0,
                    children: [
                      for (var tile in [
                        [
                          "🚨 SQL Injection (SQLi)",
                          "SQL Injection (SQLi) is a critical web security vulnerability that occurs when an attacker manipulates an application's SQL queries by injecting malicious input into form fields, URLs, or HTTP headers. This vulnerability arises when user-supplied data is directly incorporated into SQL statements without proper validation or sanitization."
                        ],
                        [
                          "⚠️ Cross-Site Scripting (XSS)",
                          "Cross-Site Scripting (XSS) is a widespread web security vulnerability that occurs when an application fails to properly sanitize user input, allowing attackers to inject malicious scripts into trusted web pages. These scripts are then executed in the context of a user's browser, leading to various security risks such as data theft, session hijacking, website defacement, and phishing attacks."
                        ],
                        [
                          "🔄 Cross-Site Request Forgery (CSRF)",
                          "Cross-Site Request Forgery (CSRF) is a web security vulnerability that forces authenticated users to unknowingly execute unwanted actions on a web application in which they are currently authenticated. An attacker leverages the victim's active session to send malicious requests, effectively tricking the server into performing actions on behalf of the user without their consent."
                        ],
                        [
                          "📂 File Inclusion Vulnerabilities",
                          "File inclusion vulnerabilities are a serious security issue that occurs when an application dynamically loads or includes files without properly validating user input. These vulnerabilities arise when an attacker can manipulate file paths or file names, leading to the inclusion of unintended files from local or remote sources. File inclusion vulnerabilities are commonly found in web applications that use scripting languages like PHP, Python, or Ruby."
                        ],
                        [
                          "🛑 Weak Security Headers",
                          "Weak security headers are a common and critical vulnerability in web applications that occur when HTTP response headers are misconfigured, missing, or improperly implemented. These headers play a crucial role in enforcing security policies within web browsers, protecting against various attacks such as cross-site scripting (XSS), clickjacking, MIME-type sniffing, and data exposure."
                        ],
                        [
                          "💻 Command Injection",
                          "Command injection is a critical security vulnerability that occurs when an application inadequately handles user input, allowing an attacker to execute arbitrary system commands on the host server. This vulnerability arises when user-supplied data is directly incorporated into command-line instructions without proper sanitization or validation."
                        ],
                        [
                          "🔓 Insecure Deserialization",
                          "Insecure deserialization is a critical security vulnerability that arises when untrusted data is deserialized without proper validation or integrity checks. This vulnerability occurs when applications accept serialized objects from untrusted sources. Attackers exploit this weakness to manipulate serialized data and inject malicious payloads, leading to severe consequences such as remote code execution (RCE), data tampering, denial of service (DoS), and privilege escalation."
                        ],
                        [
                          "📝 Directory Traversal",
                          "Directory traversal, also known as path traversal, is a web security vulnerability that allows an attacker to access files and directories stored outside the intended directory. This vulnerability occurs when the application fails to properly sanitize user-supplied input, leading to unauthorized access to sensitive files and system information."
                        ],
                        [
                          "🌐 Server Side Request Forgery (SSRF)",
                          "Server-Side Request Forgery (SSRF) is a critical web vulnerability that occurs when an attacker manipulates a server to send unauthorized requests to internal or external systems. Unlike client-side attacks, SSRF targets the server itself, exploiting its ability to perform HTTP or other protocol-based requests on behalf of the attacker."
                        ],
                        [
                          "🔑 Weak Authentication Mechanisms",
                          "Weak authentication mechanisms are a significant security vulnerability in modern applications, posing severe risks to data confidentiality, integrity, and system availability. These vulnerabilities arise when authentication processes are poorly designed, implemented, or configured, allowing unauthorized users to gain access to sensitive systems and data."
                        ]
                      ])
                        GestureDetector(
                          onTap: () {
                            print("Tile clicked: ${tile[0]}");
                            // Add any desired onClick functionality here.
                          },
                          child: MouseRegion(
                            onEnter: (_) {},
                            onExit: (_) {},
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              transform: Matrix4.identity()..scale(1.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tile[0],
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tile[1],
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
