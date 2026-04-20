import http.server
import socketserver
import json

PORT = 3001

class APIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        print(f"Request path: {self.path}")
        
        path = self.path
        
        if path.startswith('/api'):
            path = path[4:] or '/'
            print(f"  -> cleaned: {path}")
        
        if path == '/users':
            self.send_json([{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}])
        elif path == '/status':
            self.send_json({"status": "online", "port": PORT})
        elif path == '/' or path == '':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            try:
                with open('index.html', 'rb') as f:
                    self.wfile.write(f.read())
            except:
                self.wfile.write(b'<h1>API Service</h1><p>Port: 3001</p>')
        else:
            self.send_error(404, "Not Found")
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

with socketserver.TCPServer(("127.0.0.1", PORT), APIHandler) as httpd:
    print(f"API: http://127.0.0.1:{PORT}")
    httpd.serve_forever()

    