// app.js - Time Here Now API Example Application
// Demonstrates all features of the @rodit/rodit-auth-be SDK

const https = require("https");
const fs = require("fs");
const path = require("path");
const express = require("express");
const { ulid } = require("ulid");

// Import from @rodit/rodit-auth-be SDK
const { 
  RoditClient,
  stateManager,
} = require('@rodit/rodit-auth-be');

// Initialize temporary client for early logging setup
const tempClient = new RoditClient();
const logger = tempClient.getLogger();
const loggingmw = tempClient.getLoggingMiddleware();
const config = tempClient.getConfig();

// Configure Loki logging if enabled
(() => {
  try {
    const lokiUrl = config.get('LOKI_URL', process.env.LOKI_URL);
    const logLevel = config.get('LOG_LEVEL', process.env.LOG_LEVEL || "info");
    const basicAuth = config.get('LOKI_BASIC_AUTH', process.env.LOKI_BASIC_AUTH);
    const serviceName = config.get('SERVICE_NAME');

    const winston = require('winston');
    const LokiTransport = require('winston-loki');

    const transports = [
      new winston.transports.Console({ format: winston.format.json(), level: logLevel })
    ];

    if (lokiUrl) {
      const lokiOptions = {
        host: lokiUrl,
        labels: { 
          app: "timeherenow", 
          component: "api",
          service: serviceName
        },
        json: true,
        level: logLevel,
        batching: true,
        gracefulShutdown: true,
        replaceTimestamp: true,
        timeout: 5000,
      };

      if (basicAuth) {
        lokiOptions.basicAuth = basicAuth;
      }

      const lokiTransport = new LokiTransport(lokiOptions);
      
      lokiTransport.on('error', (err) => {
        console.error("Loki transport error:", err.message);
      });

      transports.push(lokiTransport);
      console.log("✅ Loki logging enabled");
    }

    const customLogger = winston.createLogger({
      level: logLevel,
      format: winston.format.json(),
      transports,
    });

    logger.setLogger(customLogger);
  } catch (e) {
    console.warn("Loki logger setup failed:", e?.message || e);
  }
})();

// Initialize Express app
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Log application startup
logger.info("Starting Time Here Now API Example", {
  nodeEnv: process.env.NODE_ENV || "development",
  pid: process.pid,
  nodeVersion: process.version,
});

// Apply SDK logging middleware
app.use(loggingmw);

// Request context middleware
app.use((req, res, next) => {
  req.startTime = Date.now();
  req.requestId = req.headers['x-request-id'] || ulid();
  next();
});

// Store for received webhooks (for demonstration)
const receivedWebhooks = [];

// Webhook endpoint - demonstrates SDK webhook handling
app.post("/webhook", async (req, res) => {
  const requestId = req.requestId || ulid();
  
  try {
    logger.info("Webhook received", {
      component: "Webhook",
      requestId,
      event: req.body.event,
      hasPayload: !!req.body.payload
    });
    
    // Store webhook for demonstration
    receivedWebhooks.push({
      timestamp: new Date().toISOString(),
      event: req.body.event,
      data: req.body.data,
      requestId
    });
    
    // Keep only last 100 webhooks
    if (receivedWebhooks.length > 100) {
      receivedWebhooks.shift();
    }
    
    res.json({ 
      success: true, 
      message: "Webhook received",
      requestId 
    });
  } catch (error) {
    logger.error("Webhook processing error", {
      component: "Webhook",
      requestId,
      error: error.message
    });
    res.status(500).json({ error: error.message, requestId });
  }
});

// Endpoint to view received webhooks
app.get("/webhooks", (req, res) => {
  res.json({
    count: receivedWebhooks.length,
    webhooks: receivedWebhooks.slice(-20) // Last 20
  });
});

// Global variables
let roditClient;
let server;

// Main server initialization
async function startServer() {
  try {
    // Initialize the RODiT SDK client
    roditClient = await RoditClient.create('client');
    app.locals.roditClient = roditClient;
    
    logger.info("RODiT SDK initialized", {
      component: "Server"
    });

    // Get webhook URL from RODiT token metadata
    const configOwnRodit = await stateManager.getConfigOwnRodit();
    const webhookUrl = configOwnRodit?.own_rodit?.metadata?.webhook_url;
    
    if (!webhookUrl) {
      throw new Error('webhook_url not found in RODiT token metadata');
    }
    
    // Extract port from webhook URL
    const urlMatch = webhookUrl.match(/:([0-9]+)$/);
    const WEBHOOKPORT = urlMatch ? parseInt(urlMatch[1], 10) : 443;
    
    logger.info("Using webhook configuration", {
      component: "Server",
      webhookUrl,
      port: WEBHOOKPORT
    });

    // Load SSL certificates
    const httpsOptions = {
      key: fs.readFileSync(path.join(__dirname, '../certs/privkey.pem')),
      cert: fs.readFileSync(path.join(__dirname, '../certs/fullchain.pem'))
    };

    // Start HTTPS server
    server = https.createServer(httpsOptions, app).listen(WEBHOOKPORT, () => {
      logger.info(`HTTPS Server started on port ${WEBHOOKPORT}`, {
        component: "Server",
        protocol: "https",
        webhookUrl
      });
    });

    // Run example demonstrations
    await runExamples();

    return server;
  } catch (error) {
    logger.error(`Failed to start server: ${error.message}`, {
      component: "Server",
      error: error.stack
    });
    process.exit(1);
  }
}

// Example demonstrations of SDK features
async function runExamples() {
  try {
    logger.info("=== Running SDK Feature Examples ===", {
      component: "Examples"
    });

    // Example 1: Authentication
    logger.info("Example 1: Server Authentication", {
      component: "Examples"
    });
    const loginResult = await roditClient.login_server();
    if (loginResult.jwt_token) {
      logger.info("✓ Authentication successful", {
        component: "Examples",
        hasToken: true
      });
    }

    // Example 2: Configuration Access
    logger.info("Example 2: Accessing RODiT Configuration", {
      component: "Examples"
    });
    const configOwnRodit = await roditClient.getConfigOwnRodit();
    const metadata = configOwnRodit?.own_rodit?.metadata;
    logger.info("✓ Configuration retrieved", {
      component: "Examples",
      hasMetadata: !!metadata,
      apiEndpoint: metadata?.subjectuniqueidentifier_url,
      webhookUrl: metadata?.webhook_url
    });

    // Example 3: Session Management
    logger.info("Example 3: Session Management", {
      component: "Examples"
    });
    const sessionManager = roditClient.getSessionManager();
    const activeCount = await sessionManager.getActiveSessionCount();
    logger.info("✓ Session manager accessed", {
      component: "Examples",
      activeSessions: activeCount
    });

    // Example 4: Performance Metrics
    logger.info("Example 4: Performance Metrics", {
      component: "Examples"
    });
    const performanceService = roditClient.getPerformanceService();
    if (performanceService) {
      const metrics = performanceService.getMetrics();
      logger.info("✓ Performance metrics retrieved", {
        component: "Examples",
        requestCount: metrics.requestCount,
        errorCount: metrics.errorCount
      });
    }

    logger.info("=== SDK Feature Examples Complete ===", {
      component: "Examples"
    });
  } catch (error) {
    logger.error("Error running examples", {
      component: "Examples",
      error: error.message
    });
  }
}

// Graceful shutdown handlers
process.on("SIGTERM", () => {
  logger.info("SIGTERM received: shutting down");
  server?.close(() => {
    logger.info("Server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  logger.info("SIGINT received: shutting down");
  server?.close(() => {
    logger.info("Server closed");
    process.exit(0);
  });
});

// Start the server
startServer().catch(error => {
  logger.error("Fatal error:", error);
  process.exit(1);
});

module.exports = { app };