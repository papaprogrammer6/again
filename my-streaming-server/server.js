const NodeMediaServer = require('node-media-server');

const config = {
  rtmp: {
    port: 1935,
    chunk_size: 4096,  // Reduce chunk size to lower latency
    gop_cache: false,  // Disable GOP cache to reduce latency
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: 8000,
    allow_origin: '*'
  },
  relay: {
    ffmpeg: '/path/to/ffmpeg',
    tasks: [
      {
        app: 'live',
        mode: 'push',
        edge: 'rtmp://localhost/live',
        name: 'mystream',
        rtsp_transport : 'tcp' //['udp', 'tcp', 'udp_multicast', 'http']
      }
    ]
  }
};

var nms = new NodeMediaServer(config)
nms.run();
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const SERVER_SCRIPT = path.join(__dirname, 'server.js');
const PID_FILE = path.join(__dirname, 'server.pid');
const LOG_FILE = path.join(__dirname, 'server.log');

function startServer() {
  const server = spawn('node', [SERVER_SCRIPT], {
    detached: true,
    stdio: ['ignore', fs.openSync(LOG_FILE, 'a'), fs.openSync(LOG_FILE, 'a')]
  });

  fs.writeFileSync(PID_FILE, server.pid.toString());
  console.log(`Server started with PID ${server.pid}`);
  server.unref();
}

function stopServer() {
  if (fs.existsSync(PID_FILE)) {
    const pid = parseInt(fs.readFileSync(PID_FILE, 'utf8'), 10);
    try {
      process.kill(pid);
      fs.unlinkSync(PID_FILE);
      console.log(`Server with PID ${pid} stopped`);
    } catch (err) {
      console.error(`Failed to stop server: ${err.message}`);
    }
  } else {
    console.log('Server is not running');
  }
}

function main() {
  const command = process.argv[2];
  switch (command) {
    case 'start':
      startServer();
      break;
    case 'stop':
      stopServer();
      break;
    default:
      console.log('Usage: node server-manager.js [start|stop]');
  }
}

main();

console.log('Streaming server running on rtmp://localhost:1935');
console.log('HLS stream available at http://localhost:8000/live/mystream.flv');