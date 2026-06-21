#!/usr/bin/env python3
"""Minimal demo backend: serves JSON on 127.0.0.1:8080 for the tunnel to point at."""
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

HOST, PORT = "127.0.0.1", 8080


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps(
            {"service": "example-service", "status": "ok", "path": self.path}
        ).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    print(f"Serving JSON on http://{HOST}:{PORT}")
    HTTPServer((HOST, PORT), Handler).serve_forever()
