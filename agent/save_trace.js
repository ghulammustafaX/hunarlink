const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Run scratch.js and capture output
const output = execSync('node scratch.js', {
  encoding: 'utf8',
  cwd: __dirname,
});

// Write with proper UTF-8
const tracePath = path.join(__dirname, 'trace_logs', 'trace_001.txt');
fs.writeFileSync(tracePath, output, { encoding: 'utf8' });

console.log('✅ trace_001.txt saved successfully!');