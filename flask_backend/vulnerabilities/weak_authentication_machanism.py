import requests
import json
from requests.auth import HTTPBasicAuth

# Common weak credentials to test
weak_credentials = [
    ("admin", "admin"),
    ("admin", "password"),
    ("user", "user"),
    ("admin", "12345"),
    ("root", "root"),
    ("test", "test"),
    ("admin", "1234"),
    ("guest", "guest"),
    ("admin", "admin123"),
    ("root", "toor"),
    ("shaesan","shaesan"),
]

def test_weak_authentication(url, verbose=False):
    results = []

    for username, password in weak_credentials:
        try:
            # Attempt HTTP Basic Authentication
            response = requests.get(url, auth=HTTPBasicAuth(username, password), timeout=5)

            if verbose:
                print(f"[*] Trying {username}:{password} - Status Code: {response.status_code}")

            # Check if authentication was successful
            if response.status_code == 200:
                results.append({
                    "username": username,
                    "password": password,
                    "vulnerable": True,
                    "status_code": response.status_code
                })
            else:
                results.append({
                    "username": username,
                    "password": password,
                    "vulnerable": False,
                    "status_code": response.status_code
                })

        except Exception as e:
            return {"error": f"Error during authentication scanning: {str(e)}"}

    return {"results": results}
