import http.server
import json
import os
import urllib.request
import urllib.parse

# Cargar configuración desde .env o valores por defecto
ENV_PATH = os.path.join(os.path.dirname(__file__), '.env')
MOODLE_URL = "http://192.168.1.121:8080/webservice/rest/server.php"
MOODLE_TOKEN = "c1f7b6a010723ed65d2b749c3fdd0aac"
PORT = 3000

if os.path.exists(ENV_PATH):
    with open(ENV_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                k, v = line.strip().split('=', 1)
                if k == 'MOODLE_URL': MOODLE_URL = v
                elif k == 'MOODLE_TOKEN': MOODLE_TOKEN = v
                elif k == 'PORT': PORT = int(v)

class MoodleProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        try:
            req_data = json.loads(body.decode('utf-8')) if content_length > 0 else {}
        except:
            req_data = {}

        wsfunction = req_data.get('wsfunction', self.path.strip('/'))
        params = req_data.get('params', {})

        # Preparar parámetros para Moodle
        payload = {
            'wstoken': MOODLE_TOKEN,
            'wsfunction': wsfunction,
            'moodlewsrestformat': 'json'
        }
        for k, v in params.items():
            payload[k] = v

        encoded_data = urllib.parse.urlencode(payload).encode('utf-8')

        print(f"[PROXY] Solicitud a Moodle | Function: {wsfunction}")

        try:
            req = urllib.request.Request(MOODLE_URL, data=encoded_data, method='POST')
            with urllib.request.urlopen(req, timeout=10) as response:
                resp_body = response.read()
                data = json.loads(resp_body.decode('utf-8'))

                # Filtrar curso ID 1 y limpiar espacios si es core_course_get_courses
                if wsfunction == 'core_course_get_courses' and isinstance(data, list):
                    filtered = []
                    for c in data:
                        if c.get('id') != 1:
                            if 'fullname' in c: c['fullname'] = c['fullname'].strip()
                            if 'shortname' in c: c['shortname'] = c['shortname'].strip()
                            filtered.append(c)
                    data = filtered

                response_bytes = json.dumps(data).encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(response_bytes)
        except Exception as e:
            err_res = json.dumps({"error": str(e)}).encode('utf-8')
            self.send_response(500)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(err_res)

    def do_GET(self):
        self.do_POST()

if __name__ == '__main__':
    server_address = ('0.0.0.0', PORT)
    httpd = http.server.HTTPServer(server_address, MoodleProxyHandler)
    print(f"==================================================")
    print(f" IINICIA Moodle Proxy corriendo en puerto {PORT}")
    print(f" Destino Moodle: {MOODLE_URL}")
    print(f" Accesible desde Android en: http://192.168.1.121:{PORT}")
    print(f"==================================================")
    httpd.serve_forever()
