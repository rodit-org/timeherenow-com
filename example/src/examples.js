// examples.js - Comprehensive SDK Feature Examples
// Demonstrates how to use the @rodit/rodit-auth-be SDK with Time Here Now API

const { RoditClient } = require('@rodit/rodit-auth-be');

/**
 * Example 1: SDK Initialization and Authentication
 * Demonstrates: RoditClient.create(), login_server()
 * API Endpoints: POST /api/login
 */
async function example1_Authentication() {
  console.log('\n=== Example 1: Authentication ===\n');
  
  // Initialize the SDK client
  const client = await RoditClient.create('client');
  console.log('✓ SDK client initialized');
  
  // Authenticate with the server
  const loginResult = await client.login_server();
  
  if (loginResult.jwt_token) {
    console.log('✓ Authentication successful');
    console.log(`  JWT Token: ${loginResult.jwt_token.substring(0, 50)}...`);
    console.log(`  API Endpoint: ${loginResult.apiendpoint}`);
  }
  
  return client;
}

/**
 * Example 2: Configuration Access
 * Demonstrates: getConfigOwnRodit(), accessing RODiT token metadata
 * Shows: API endpoint, webhook URL, permissions, rate limits
 */
async function example2_Configuration(client) {
  console.log('\n=== Example 2: Configuration Access ===\n');
  
  // Get RODiT configuration
  const config = await client.getConfigOwnRodit();
  const metadata = config.own_rodit.metadata;
  
  console.log('✓ Configuration retrieved:');
  console.log(`  API Endpoint: ${metadata.subjectuniqueidentifier_url}`);
  console.log(`  Webhook URL: ${metadata.webhook_url}`);
  console.log(`  JWT Duration: ${metadata.jwt_duration} seconds`);
  console.log(`  Max Requests: ${metadata.max_requests}`);
  console.log(`  Rate Limit Window: ${metadata.maxrq_window} seconds`);
  
  // Parse permissioned routes
  const permissions = JSON.parse(metadata.permissioned_routes || '{}');
  console.log(`  Permissioned Routes: ${Object.keys(permissions.entities || {}).length} routes`);
  
  return config;
}

/**
 * Example 3: Making Authenticated API Calls
 * Demonstrates: Using JWT token for API requests
 * API Endpoints: POST /api/timezone, POST /api/timezone/time
 */
async function example3_AuthenticatedAPICalls(client) {
  console.log('\n=== Example 3: Authenticated API Calls ===\n');
  
  const https = require('https');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  // Example: List all timezones
  console.log('Making API call: POST /api/timezone');
  const timezones = await makeAPICall(apiEndpoint, '/api/timezone', {}, token);
  console.log(`✓ Retrieved ${timezones.length} timezones`);
  console.log(`  Sample: ${timezones.slice(0, 3).join(', ')}`);
  
  // Example: Get current time for a timezone
  console.log('\nMaking API call: POST /api/timezone/time');
  const timeData = await makeAPICall(apiEndpoint, '/api/timezone/time', {
    timezone: 'America/New_York',
    locale: 'en-US'
  }, token);
  console.log('✓ Time data retrieved:');
  console.log(`  Timezone: ${timeData.time_zone}`);
  console.log(`  Current Time: ${timeData.date_time}`);
  console.log(`  UTC Time: ${timeData.utc_datetime}`);
}

/**
 * Example 4: Session Management
 * Demonstrates: Session tracking, active session count
 * SDK Features: getSessionManager(), getActiveSessionCount()
 */
async function example4_SessionManagement(client) {
  console.log('\n=== Example 4: Session Management ===\n');
  
  const sessionManager = client.getSessionManager();
  
  // Get active session count
  const activeCount = await sessionManager.getActiveSessionCount();
  console.log(`✓ Active sessions: ${activeCount}`);
  
  // Session storage information
  const storageType = sessionManager.storage.constructor.name;
  console.log(`  Storage type: ${storageType}`);
  
  return sessionManager;
}

/**
 * Example 5: Performance Metrics
 * Demonstrates: Performance tracking and metrics collection
 * SDK Features: getPerformanceService(), getMetrics()
 * API Endpoints: GET /api/metrics, GET /api/metrics/system
 */
async function example5_PerformanceMetrics(client) {
  console.log('\n=== Example 5: Performance Metrics ===\n');
  
  const performanceService = client.getPerformanceService();
  
  if (performanceService) {
    const metrics = performanceService.getMetrics();
    console.log('✓ Performance metrics:');
    console.log(`  Total Requests: ${metrics.requestCount}`);
    console.log(`  Error Count: ${metrics.errorCount}`);
    console.log(`  Requests/Minute: ${metrics.requestsPerMinute.toFixed(2)}`);
    console.log(`  Load Level: ${metrics.currentLoadLevel}`);
  } else {
    console.log('⚠ Performance service not available');
  }
}

/**
 * Example 6: Webhook Handling
 * Demonstrates: Sending webhooks, webhook configuration
 * SDK Features: send_webhook()
 * API Endpoints: Webhook destination from RODiT metadata
 */
async function example6_Webhooks(client) {
  console.log('\n=== Example 6: Webhook Handling ===\n');
  
  const config = await client.getConfigOwnRodit();
  const webhookUrl = config.own_rodit.metadata.webhook_url;
  
  console.log(`✓ Webhook URL configured: ${webhookUrl}`);
  console.log('  Webhooks can be sent using client.send_webhook()');
  console.log('  Example payload:');
  console.log('  {');
  console.log('    event: "data_created",');
  console.log('    data: { id: 123, timestamp: "2024-01-01T00:00:00Z" },');
  console.log('    isError: false');
  console.log('  }');
}

/**
 * Example 7: Timer/Delayed Webhooks
 * Demonstrates: Scheduling delayed webhooks
 * API Endpoints: POST /api/timers/schedule
 */
async function example7_TimerWebhooks(client) {
  console.log('\n=== Example 7: Timer/Delayed Webhooks ===\n');
  
  const https = require('https');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  console.log('Scheduling a delayed webhook (10 seconds)...');
  const timerResult = await makeAPICall(apiEndpoint, '/api/timers/schedule', {
    delay_seconds: 10,
    payload: {
      message: 'Example timer webhook',
      timestamp: new Date().toISOString()
    }
  }, token);
  
  console.log('✓ Timer scheduled:');
  console.log(`  Timer ID: ${timerResult.timer_id}`);
  console.log(`  Scheduled At: ${timerResult.scheduled_at}`);
  console.log(`  Will Execute At: ${timerResult.execute_at}`);
  console.log(`  Delay: ${timerResult.delay_seconds} seconds`);
}

/**
 * Example 8: IP-Based Time Lookup
 * Demonstrates: Getting time based on IP geolocation
 * API Endpoints: POST /api/ip
 */
async function example8_IPBasedTime(client) {
  console.log('\n=== Example 8: IP-Based Time Lookup ===\n');
  
  const https = require('https');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  console.log('Getting time based on client IP...');
  const timeData = await makeAPICall(apiEndpoint, '/api/ip', {
    locale: 'en-US'
  }, token);
  
  console.log('✓ Time data for your IP:');
  console.log(`  IP Address: ${timeData.user_ip}`);
  console.log(`  Detected Timezone: ${timeData.time_zone}`);
  console.log(`  Current Time: ${timeData.date_time}`);
  console.log(`  UTC Offset: ${timeData.utc_offset}`);
}

/**
 * Example 9: Hash Signing with NEAR Timestamp
 * Demonstrates: Cryptographic signing with blockchain timestamp
 * API Endpoints: POST /api/sign/hash
 */
async function example9_HashSigning(client) {
  console.log('\n=== Example 9: Hash Signing with NEAR Timestamp ===\n');
  
  const https = require('https');
  const crypto = require('crypto');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  // Create a sample hash
  const hash = crypto.createHash('sha256').update('example data').digest();
  const hashB64url = hash.toString('base64url');
  
  console.log('Signing hash with NEAR blockchain timestamp...');
  const signResult = await makeAPICall(apiEndpoint, '/api/sign/hash', {
    hash_b64url: hashB64url
  }, token);
  
  console.log('✓ Hash signed:');
  console.log(`  Hash: ${signResult.data.hash_b64url.substring(0, 40)}...`);
  console.log(`  Timestamp: ${signResult.data.timestamp_iso}`);
  console.log(`  Time Difference: ${signResult.data.likely_time_difference_ms}ms`);
  console.log(`  Signature: ${signResult.signature_base64url.substring(0, 40)}...`);
}

/**
 * Example 10: Timezone Queries
 * Demonstrates: Various timezone query methods
 * API Endpoints: POST /api/timezone/area, POST /api/timezones/by-country
 */
async function example10_TimezoneQueries(client) {
  console.log('\n=== Example 10: Timezone Queries ===\n');
  
  const https = require('https');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  // Query by area
  console.log('Querying timezones for America...');
  const americaZones = await makeAPICall(apiEndpoint, '/api/timezone/area', {
    area: 'America'
  }, token);
  console.log(`✓ Found ${americaZones.length} timezones in America`);
  console.log(`  Sample: ${americaZones.slice(0, 3).join(', ')}`);
  
  // Query by country
  console.log('\nQuerying timezones for United States (US)...');
  const usZones = await makeAPICall(apiEndpoint, '/api/timezones/by-country', {
    country_code: 'US'
  }, token);
  console.log(`✓ Found ${usZones.length} timezones in US`);
  console.log(`  Sample: ${usZones.slice(0, 3).join(', ')}`);
}

/**
 * Example 11: Logging and Monitoring
 * Demonstrates: SDK logging capabilities
 * SDK Features: getLogger(), structured logging
 */
async function example11_Logging(client) {
  console.log('\n=== Example 11: Logging and Monitoring ===\n');
  
  const logger = client.getLogger();
  
  console.log('✓ Logger configured');
  console.log('  Available methods:');
  console.log('  - logger.info(message, context)');
  console.log('  - logger.warn(message, context)');
  console.log('  - logger.error(message, context)');
  console.log('  - logger.debug(message, context)');
  console.log('  - logger.infoWithContext(message, context)');
  console.log('  - logger.errorWithContext(message, context, error)');
  
  // Example structured log
  logger.info('Example structured log', {
    component: 'Examples',
    feature: 'Logging',
    timestamp: new Date().toISOString()
  });
  
  console.log('✓ Structured log emitted');
}

/**
 * Example 12: MCP (Model Context Protocol) Resources
 * Demonstrates: AI-accessible resource discovery
 * API Endpoints: GET /api/mcp/resources, GET /api/mcp/resource/:uri
 */
async function example12_MCPResources(client) {
  console.log('\n=== Example 12: MCP Resources (AI Discovery) ===\n');
  
  const https = require('https');
  const config = await client.getConfigOwnRodit();
  const apiEndpoint = config.own_rodit.metadata.subjectuniqueidentifier_url;
  const loginResult = await client.login_server();
  const token = loginResult.jwt_token;
  
  console.log('Listing MCP resources...');
  const resources = await makeAPICall(apiEndpoint, '/api/mcp/resources', {}, token, 'GET');
  
  console.log('✓ Available MCP resources:');
  resources.resources.forEach(resource => {
    console.log(`  - ${resource.name} (${resource.uri})`);
  });
}

// Helper function to make API calls
function makeAPICall(apiEndpoint, path, body, token, method = 'POST') {
  return new Promise((resolve, reject) => {
    const url = new URL(apiEndpoint);
    const options = {
      hostname: url.hostname,
      port: url.port || 8443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      rejectUnauthorized: false // For self-signed certs in development
    };
    
    const https = require('https');
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve(data);
        }
      });
    });
    
    req.on('error', reject);
    
    if (method === 'POST' && body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

// Run all examples
async function runAllExamples() {
  try {
    console.log('\n╔═══════════════════════════════════════════════════════════╗');
    console.log('║  Time Here Now API - SDK Feature Examples                ║');
    console.log('║  Demonstrates @rodit/rodit-auth-be SDK capabilities      ║');
    console.log('╚═══════════════════════════════════════════════════════════╝');
    
    const client = await example1_Authentication();
    await example2_Configuration(client);
    await example3_AuthenticatedAPICalls(client);
    await example4_SessionManagement(client);
    await example5_PerformanceMetrics(client);
    await example6_Webhooks(client);
    await example7_TimerWebhooks(client);
    await example8_IPBasedTime(client);
    await example9_HashSigning(client);
    await example10_TimezoneQueries(client);
    await example11_Logging(client);
    await example12_MCPResources(client);
    
    console.log('\n╔═══════════════════════════════════════════════════════════╗');
    console.log('║  All Examples Completed Successfully!                    ║');
    console.log('╚═══════════════════════════════════════════════════════════╝\n');
    
  } catch (error) {
    console.error('\n❌ Error running examples:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// Export for use in other modules
module.exports = {
  example1_Authentication,
  example2_Configuration,
  example3_AuthenticatedAPICalls,
  example4_SessionManagement,
  example5_PerformanceMetrics,
  example6_Webhooks,
  example7_TimerWebhooks,
  example8_IPBasedTime,
  example9_HashSigning,
  example10_TimezoneQueries,
  example11_Logging,
  example12_MCPResources,
  runAllExamples
};

// Run if called directly
if (require.main === module) {
  runAllExamples();
}
