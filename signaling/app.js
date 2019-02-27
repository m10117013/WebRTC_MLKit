const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 }, () => {
    console.log("Signaling server is now listening on port 8080")
});

// Broadcast to all exclude self.
wss.broadcast = (ws, data) => {
    wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(data);
        }
    });
};

// Broadcast to all 
wss.broadcastAll = (ws, data) => {
    wss.clients.forEach((client) => {
            client.send(data);
    });
};

wss.on('connection', (ws) => {
    console.log(`Client connected. Total connected clients: ${wss.clients.size}`)
    
    if (wss.clients.size > 1) {
	    wss.broadcastAll(ws, "{\"t\":\"r\"}");
    }
    
    ws.onmessage = (message) => {
        console.log(message.data + "\n");
        wss.broadcast(ws, message.data);
    }

    ws.onclose = () => {
        console.log(`Client disconnected. Total connected clients: ${wss.clients.size}`)
    }
});