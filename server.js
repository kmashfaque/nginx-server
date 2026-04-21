const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} request to ${req.url}`);
    next();
});

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        message: 'Backend server is running',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/info', (req, res) => {
    res.json({
        server: 'Node.js Backend',
        port: PORT,
        protocol: req.protocol,
        ip: req.ip,
        headers: req.headers
    });
});

app.get('/api/data', (req, res) => {
    res.json({
        message: 'Data from backend server',
        data: [
            { id: 1, name: 'Item One' },
            { id: 2, name: 'Item Two' },
            { id: 3, name: 'Item Three' }
        ]
    });
});

app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

app.listen(PORT, () => {
    console.log(`Backend server running on http://localhost:${PORT}`);
    console.log(`API endpoints:`);
    console.log(`  - GET /api/health`);
    console.log(`  - GET /api/info`);
    console.log(`  - GET /api/data`);
});
