import http.server
import socketserver
import json

PORT = 3002

class AppHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "healthy"}).encode())
        else:
            if self.path.endswith('.html') or self.path == '/':
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()

                with open('index.html', 'rb') as f:
                    self.wfile.write(f.read())
            else:
                super().do_GET()
    
    def log_message(self, format, *args):
        print(f"[App] {self.address_string()} - {format % args}")

with socketserver.TCPServer(("127.0.0.1", PORT), AppHandler) as httpd:
    print(f"📱 App Service: http://127.0.0.1:{PORT}")
    httpd.serve_forever()

    