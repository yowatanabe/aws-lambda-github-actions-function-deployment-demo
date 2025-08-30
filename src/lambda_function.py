import json

import requests


def handler(event, context):
    url = "https://example.com"
    try:
        resp = requests.get(url, timeout=5)
        resp.raise_for_status()
        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "ok": True,
                    "message": f"Successfully accessed {url}",
                    "status_code": resp.status_code,
                }
            ),
        }
    except requests.exceptions.RequestException as e:
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"ok": False, "message": f"Failed to access {url}", "error": str(e)}
            ),
        }
