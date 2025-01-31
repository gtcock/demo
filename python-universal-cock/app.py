import os
import io
import requests
import platform
from flask import Flask, send_file
from subprocess import Popen, PIPE, STDOUT
import threading
import time

# 配置变量
class Config:
    TOKEN = os.getenv('Token', 'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiY2E5ZmM4ZDItMTM0Ni00NjkxLTgxODYtN2ZkMDZkNDQwZjlkIiwicyI6Ik1qWTJPREkzTW1RdE1qVXhPUzAwTmpjNExXSTNaR1F0T1dReE56TmtZMkkxWTJZdyJ9')
    BOT_KEY = os.getenv('BOT_KEY', 'NzrejmhnKtZQO36KtO')
    WORK_DIR = '/tmp'
    PORT = int(os.getenv('PORT', 8080))

class ServiceManager:
    def __init__(self):
        self.app = Flask(__name__)
        self.file_contents = {}
        self.processes = {
            'server': None,
            'web': None,
            'bot': None
        }
        self.setup_routes()

    def setup_routes(self):
        @self.app.route('/')
        def index():
            return self.handle_index()

        @self.app.route('/health')
        def health():
            return 'OK', 200

    def get_system_arch(self):
        machine = platform.machine().lower()
        return 'arm64' if machine in ['arm64', 'aarch64'] else 'amd64'

    def get_download_list(self):
        arch = self.get_system_arch()
        print(f"Detected system architecture: {arch}")
        
        base_files = [
            {
                'url': 'https://github.com/gtcock/demo/releases/download/cock/index.html',
                'filename': 'index.html',
            },
            {
                'url': 'https://github.com/gtcock/demo/releases/download/cock/config.json',
                'filename': 'config.json',
            }
        ]

        arch_specific_files = [
            {
                'url': f'https://github.com/gtcock/demo/releases/download/cock/server{"-arm64" if arch == "arm64" else ""}',
                'filename': 'server',
            },
            {
                'url': f'https://github.com/gtcock/demo/releases/download/cock/web{"-arm64" if arch == "arm64" else ""}',
                'filename': 'web',
            },
            {
                'url': f'https://github.com/gtcock/demo/releases/download/cock/bot{"-arm64" if arch == "arm64" else ""}',
                'filename': 'bot',
            }
        ]

        return base_files + arch_specific_files

    def download_file(self, url, filename):
        print(f'Downloading file from {url}...')
        try:
            response = requests.get(url)
            response.raise_for_status()
            self.file_contents[filename] = response.content
            print(f'Successfully downloaded {filename}')
            return True
        except requests.RequestException as error:
            print(f'Failed to download {filename}: {error}')
            return False

    def write_temp_files(self):
        try:
            print("\n=== Writing files to disk ===")
            for filename, content in self.file_contents.items():
                filepath = os.path.join(Config.WORK_DIR, filename)
                with open(filepath, 'wb') as f:
                    f.write(content)
                if filename in ['server', 'web', 'bot']:
                    os.chmod(filepath, 0o755)
                print(f"Successfully wrote {filename}")
            return True
        except Exception as e:
            print(f"Failed to write files: {e}")
            return False

    def start_service(self, name, args):
        try:
            filepath = os.path.join(Config.WORK_DIR, name)
            full_cmd = [filepath] + args
            print(f"Starting {name} with command: {' '.join(full_cmd)}")
            
            if not os.path.exists(filepath):
                print(f"Error: {filepath} does not exist!")
                return False
                
            if not os.access(filepath, os.X_OK):
                print(f"Error: {filepath} is not executable!")
                return False

            process = Popen(full_cmd, 
                          stdout=PIPE,
                          stderr=STDOUT,
                          cwd=Config.WORK_DIR)
            
            time.sleep(2)
            
            if process.poll() is not None:
                print(f"{name} failed to start! Exit code: {process.poll()}")
                output = process.stdout.read().decode('utf-8')
                print(f"{name} output: {output}")
                return False
                
            self.processes[name] = process.pid
            print(f"{name} started successfully with PID: {process.pid}")
            return True
        except Exception as e:
            print(f"Failed to start {name}: {str(e)}")
            return False

    def check_process(self, pid):
        try:
            os.kill(pid, 0)
            return True
        except OSError:
            return False

    def monitor_services(self):
        def monitor():
            while True:
                try:
                    if self.processes['server'] and not self.check_process(self.processes['server']):
                        print("Server process died, restarting...")
                        self.start_service('server', ['tunnel', '--edge-ip-version', 'auto', 'run', '--token', Config.TOKEN])

                    if self.processes['web'] and not self.check_process(self.processes['web']):
                        print("Web process died, restarting...")
                        self.start_service('web', ['run', '-c', 'config.json'])

                    if self.processes['bot'] and not self.check_process(self.processes['bot']):
                        print("Bot process died, restarting...")
                        self.start_service('bot', ['-s', 'nezha.godtop.us.kg:443', '-p', Config.BOT_KEY, '--tls'])

                except Exception as e:
                    print(f"Monitor error: {e}")

                time.sleep(30)

        monitor_thread = threading.Thread(target=monitor, daemon=True)
        monitor_thread.start()

    def init_app(self):
        try:
            print("\n=== Starting initialization ===")
            print("Checking working directory...")
            if not os.path.exists(Config.WORK_DIR):
                os.makedirs(Config.WORK_DIR)
                print(f"Created working directory: {Config.WORK_DIR}")
                
            print("\n=== Downloading files ===")
            files_to_download = self.get_download_list()
            for file in files_to_download:
                if not self.download_file(file['url'], file['filename']):
                    print(f"Failed to download {file['filename']}")
                    return False

            if not self.write_temp_files():
                print("Failed to write files to disk")
                return False

            print("\n=== Starting services ===")
            print("\nStarting server...")
            if not self.start_service('server', ['tunnel', '--edge-ip-version', 'auto', 'run', '--token', Config.TOKEN]):
                print("Failed to start server")
                return False
            time.sleep(2)

            print("\nStarting web...")
            if not self.start_service('web', ['run', '-c', 'config.json']):
                print("Failed to start web")
                return False
            time.sleep(2)

            print("\nStarting bot...")
            if not self.start_service('bot', ['-s', 'nezha.godtop.us.kg:443', '-p', Config.BOT_KEY, '--tls']):
                print("Failed to start bot")
                return False

            print("\n=== Starting service monitor ===")
            self.monitor_services()
            print("Initialization completed successfully!")
            return True
        except Exception as e:
            print(f"Initialization failed: {str(e)}")
            return False

    def handle_index(self):
        try:
            if not hasattr(self.app, '_initialized'):
                if self.init_app():
                    self.app._initialized = True
                else:
                    return 'Failed to initialize', 500

            if 'index.html' in self.file_contents:
                return send_file(
                    io.BytesIO(self.file_contents['index.html']),
                    mimetype='text/html'
                )
            else:
                return 'index.html not found', 404
        except Exception as e:
            return f'Error loading index.html: {e}', 500

    def run(self):
        print("\n=== Starting Flask application ===")
        if not hasattr(self.app, '_initialized'):
            if not self.init_app():
                print("Failed to initialize services!")
                return
        self.app.run(host='0.0.0.0', port=Config.PORT)

def main():
    service_manager = ServiceManager()
    service_manager.run()

if __name__ == '__main__':
    main()