from flask import Flask, request, jsonify
import requests
from urllib.parse import urlparse

app = Flask(__name__)

# Internal IP ranges to block (can be expanded as needed)
BLOCKED_IP_RANGES = [
    "127.",      # Loopback
    "10.",       # Private network
    "172.16.",   # Private network
    "192.168.",  # Private network
    "169.254.",  # Link-local
    "0.0.0.0",   # Invalid address
    "::1"        # IPv6 loopback
]

def is_internal_ip(url):
    try:
        parsed_url = urlparse(url)
        ip = parsed_url.hostname
        if any(ip.startswith(block) for block in BLOCKED_IP_RANGES):
            return True
        return {"vulnerable": False}
    except Exception:
        return {"vulnerable": True, "reason": "No SSRF token detected in form submission."}  # Treat any parsing error as internal for safety

@app.route('/scan', methods=['POST'])
def scan_url():
    data = request.get_json()
    url = data.get("url")

    if not url:
        return jsonify({"error": "No URL provided"}), 400

    if is_internal_ip(url):
        return jsonify({"error": "Access to internal IP addresses is blocked"}), 403

    try:
        # Perform an HTTP GET request
        response = requests.get(url, timeout=5)
        result = {
            "status_code": response.status_code,
            "headers": dict(response.headers),
            "content_snippet": response.text[:200]  # Limit response content size
        }
        return jsonify(result), 200
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500
