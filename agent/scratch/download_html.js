const fs = require('fs');
const path = require('path');

const screens = [
  {
    name: '1_found_providers.html',
    url: 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzUyYjUzODU5MzIwNTQ3NWFiYTA4NmUzMDQ5YmQ4YmJiEgsSBxDhqfPrigcYAZIBIwoKcHJvamVjdF9pZBIVQhMzMzM2NTQ4MTUyNDgxNDc0NTE4&filename=&opi=89354086'
  },
  {
    name: '2_agent_processing.html',
    url: 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzMyZmJkZGIzMTIwOTQwOTNiNTk3ZjUyZWE3Y2U5YTU1EgsSBxDhqfPrigcYAZIBIwoKcHJvamVjdF9pZBIVQhMzMzM2NTQ4MTUyNDgxNDc0NTE4&filename=&opi=89354086'
  },
  {
    name: '3_success.html',
    url: 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzNkNTc5MmVhMmE5NjQwOWI4YmU5ZGJmYWIzNjNiNDIxEgsSBxDhqfPrigcYAZIBIwoKcHJvamVjdF9pZBIVQhMzMzM2NTQ4MTUyNDgxNDc0NTE4&filename=&opi=89354086'
  },
  {
    name: '4_home.html',
    url: 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzVhYWFhM2M1MGY2NjQ4YTRiZDg0NDNkZjc4ZTE0MjhkEgsSBxDhqfPrigcYAZIBIwoKcHJvamVjdF9pZBIVQhMzMzM2NTQ4MTUyNDgxNDc0NTE4&filename=&opi=89354086'
  },
  {
    name: '5_confirm_booking.html',
    url: 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzRkZTNhZDNhYmYyODQ4ODk5NGU5YjkxMjJmYWI1NGY5EgsSBxDhqfPrigcYAZIBIwoKcHJvamVjdF9pZBIVQhMzMzM2NTQ4MTUyNDgxNDc0NTE4&filename=&opi=89354086'
  }
];

async function downloadScreens() {
  const dir = path.join(__dirname, 'khidmat_html');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  for (const screen of screens) {
    try {
      console.log(`Downloading ${screen.name}...`);
      const res = await fetch(screen.url);
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      const html = await res.text();
      fs.writeFileSync(path.join(dir, screen.name), html, 'utf8');
      console.log(`Saved ${screen.name}`);
    } catch (err) {
      console.error(`Failed to download ${screen.name}:`, err.message);
    }
  }
}

downloadScreens();
