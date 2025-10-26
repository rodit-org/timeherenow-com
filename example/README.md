# Time Here Now API - SDK Example Application

Comprehensive example application demonstrating all features of the **@rodit/rodit-auth-be SDK** with the Time Here Now API.

**Version:** 2005.10.01  
**License:** UNLICENSED  
**Author:** Discernible Inc.

## Table of Contents

- [Overview](#overview)
- [Prerequisites & Setup](#prerequisites--setup)
  - [Getting NEAR Tokens](#getting-near-tokens)
  - [Installing near-cli-rs](#installing-near-cli-rs)
  - [Creating an Implicit Account](#creating-an-implicit-account)
  - [Purchasing a RODiT Token](#purchasing-a-rodit-token)
- [Quick Start](#quick-start)
- [SDK Features](#sdk-features)
- [Common Use Cases](#common-use-cases)
- [API Endpoints Coverage](#api-endpoints-coverage)
- [Running the Examples](#running-the-examples)
- [Code Examples](#code-examples)
- [Best Practices](#best-practices)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Overview

This repository serves as the **primary reference implementation** for developers integrating the `@rodit/rodit-auth-be` SDK. It showcases:

- ✅ All SDK features with practical examples
- ✅ Complete API endpoint coverage (20 endpoints)
- ✅ Best practices and patterns
- ✅ Production-ready code structure

**Key Technologies:**
- **SDK**: `@rodit/rodit-auth-be` v2.7.10+
- **Authentication**: RODiT (Rights Of Data In Transit) tokens with PKC
- **Time Source**: NEAR blockchain (5Hz polling, ~600ms granularity)
- **API Protocol**: HTTPS with JWT bearer authentication

## Prerequisites & Setup

Before using the Time Here Now API, you need to:
1. Get NEAR tokens
2. Install near-cli-rs
3. Create an implicit NEAR account
4. Purchase a Time Here Now RODiT token

### Getting NEAR Tokens

#### For Testing (Testnet) - FREE

1. **Get free testnet NEAR tokens** from the faucet:
   - Visit: https://near-faucet.io/
   - You'll need a testnet account first (see "Creating an Implicit Account" below)
   - Request tokens (typically 10-20 testnet NEAR)
   - **Amount needed**: 0.1-1 NEAR is sufficient for testing

#### For Production (Mainnet)

Purchase NEAR from cryptocurrency exchanges:

**Recommended Exchanges:**
- **Binance**: https://www.binance.com
- **Coinbase**: https://www.coinbase.com
- **Kraken**: https://www.kraken.com
- **KuCoin**: https://www.kucoin.com
- **Gate.io**: https://www.gate.io

**Steps:**
1. Create an account on your chosen exchange
2. Complete KYC verification (if required)
3. Deposit fiat currency or crypto
4. Purchase NEAR tokens
5. Withdraw to your NEAR wallet

**Amount needed**: ~1-5 NEAR for RODiT purchase + gas fees

### Installing near-cli-rs

`near-cli-rs` is the official Rust-based NEAR CLI tool for interacting with the NEAR blockchain.

#### Installation Methods

**Option 1: Install from crates.io (Recommended)**

```bash
# Install Rust if you haven't already
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install near-cli-rs
cargo install near-cli-rs

# Verify installation
near --version
```

**Option 2: Download Pre-built Binary**

```bash
# Linux/macOS
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/near/near-cli-rs/releases/latest/download/near-cli-rs-installer.sh | sh

# Verify installation
near --version
```

**Option 3: Build from Source**

```bash
git clone https://github.com/near/near-cli-rs.git
cd near-cli-rs
cargo build --release
sudo cp target/release/near /usr/local/bin/
```

#### Verify Installation

```bash
near --version
# Should output: near-cli-rs 0.x.x
```

### Creating an Implicit Account

Implicit accounts are NEAR accounts derived from a public key, perfect for programmatic access.

#### Step 1: Generate a New Key Pair

```bash
# Generate a new implicit account
near account create-account fund-myself \
  use-manually-provided-seed-phrase \
  network-config testnet
```

This will:
1. Generate a new seed phrase (12 or 24 words)
2. Create an implicit account ID (64-character hex string)
3. Save credentials to `~/.near-credentials/`

**Example output:**
```
Generated seed phrase: aware innocent wealth machine disagree betray spare royal hen frown inquiry matter
Implicit account ID: 0192a65a46f1e34b8ff430b419f6f8bbe4544a573e1b28e6fe9ae8b065406287
Public key: ed25519:79782ehLAZHZLHqC1FCLWL9AKopPhJ7UqoSSFJm7dEv
Private key: ed25519:5kTVn9TCAm7WSVmnJ2RBN6VVa732pdhR5hmxHww5YepJPhzizcK5fV2vgYKcEX4opMMmEznyC ySRvx8R3jb1AS9C
```

**IMPORTANT**: Save your seed phrase securely! You'll need it to recover your account.

#### Step 2: Fund Your Account (Testnet)

```bash
# Get free testnet NEAR from the faucet
# Visit: https://near-faucet.io/
# Enter your implicit account ID
```

#### Step 3: Verify Your Account

```bash
# Check account balance
near tokens <YOUR_IMPLICIT_ACCOUNT_ID> \
  network-config testnet

# Example:
near tokens 0192a65a46f1e34b8ff430b419f6f8bbe4544a573e1b28e6fe9ae8b065406287 \
  network-config testnet
```

#### Step 4: Export Credentials as Base64

For use in the SDK, you need to encode your credentials as base64:

```bash
# Create a JSON file with your credentials
cat > my-credentials.json << EOF
{
  "implicit_account_id": "YOUR_IMPLICIT_ACCOUNT_ID",
  "master_seed_phrase": "your twelve word seed phrase here",
  "private_key": "ed25519:YOUR_PRIVATE_KEY",
  "public_key": "ed25519:YOUR_PUBLIC_KEY",
  "seed_phrase_hd_path": "m/44'/397'/0'"
}
EOF

# Encode to base64 (single line, no wrapping)
base64 -w 0 my-credentials.json > credentials-b64.txt

# Or on macOS:
base64 -i my-credentials.json -o credentials-b64.txt

# View the base64 string
cat credentials-b64.txt
```

**Add to your configuration:**

```json
{
  "RODIT_NEAR_CREDENTIALS_SOURCE": "env",
  "NEAR_CREDENTIALS_JSON_B64": "<paste-base64-string-here>"
}
```

### Purchasing a RODiT Token

RODiT (Rights Of Data In Transit) tokens are NFTs on the NEAR blockchain that represent API access rights.

#### What is a RODiT Token?

Each RODiT token contains:
- **Authentication credentials** (public/private key pairs)
- **API service configuration** (endpoints, permissions, rate limits)
- **Subscription information** (start date, expiration date)
- **Network access parameters** (IP ranges, ports, bandwidth limits)

**Learn more**: https://vaceituno.medium.com/unleashing-the-power-of-public-key-cryptography-with-non-fungible-tokens-513286d47524

#### Purchase Process

**Step 1: Ensure You Have NEAR Tokens**

```bash
# Check your balance
near tokens <YOUR_ACCOUNT_ID> network-config testnet

# You need at least 0.5-1 NEAR for purchase + gas fees
```

**Step 2: Access the Purchase Portal**

1. Navigate to: **https://purchase.timeherenow.com**
2. Connect your NEAR wallet:
   - NEAR Wallet
   - MyNearWallet
   - Meteor Wallet
   - Or use near-cli-rs for programmatic purchase
3. Ensure you're on the correct network (testnet or mainnet)

**Step 3: Configure Your RODiT**

1. Browse available API services
2. Select **Time Here Now API**
3. Choose the number of client RODiTs needed
4. Configure parameters:
   - **Expiration date**: How long the token is valid
   - **Max requests**: Rate limit (requests per window)
   - **Request window**: Time window for rate limiting (seconds)
   - **Permissions**: Which API endpoints you can access
   - **Webhook URL**: Where to receive timer webhooks

**Step 4: Complete Purchase**

1. Review the configuration
2. Confirm the transaction in your wallet
3. Wait for blockchain confirmation (1-2 seconds)
4. Your RODiT token ID will be displayed

**Step 5: Retrieve Your RODiT Token**

After purchase, extract your RODiT credentials:

```bash
# View all your RODiT tokens
near contract call-function as-read-only \
  20251018-rodit-org.testnet \
  nft_tokens_for_owner \
  json-args '{"account_id": "YOUR_ACCOUNT_ID"}' \
  network-config testnet \
  now

# Get specific RODiT metadata
near contract call-function as-read-only \
  20251018-rodit-org.testnet \
  nft_token \
  json-args '{"token_id": "YOUR_TOKEN_ID"}' \
  network-config testnet \
  now
```

**Step 6: Configure Your Application**

The RODiT token metadata contains all the information needed for authentication. The SDK will automatically:
1. Extract the private key from your RODiT
2. Configure API endpoints from metadata
3. Set up rate limiting based on token parameters
4. Configure webhook destinations

#### Security Best Practices

⚠️ **CRITICAL SECURITY NOTES**:

- ❌ **Never expose private keys** in logs or public repositories
- ✅ **Use environment variables** or secure vaults (HashiCorp Vault)
- ✅ **Monitor expiration dates** and renew RODiT tokens before they expire
- ✅ **Verify RODiT ownership** on-chain before each API session
- ✅ **Use base64 encoding** for credentials in configuration
- ✅ **Rotate credentials** regularly
- ✅ **Use separate RODiTs** for development and production

#### For AI Agents: Automated Purchase

For programmatic RODiT purchase:

```bash
# Ensure wallet is funded
near tokens <YOUR_ACCOUNT> network-config testnet

# Call the purchase/mint function
near contract call-function as-transaction \
  20251018-rodit-org.testnet \
  purchase_rodit \
  json-args '{
    "service_type": "timeherenow",
    "duration_days": 30,
    "max_requests": 1000,
    "request_window": 60
  }' \
  prepaid-gas '100.0 Tgas' \
  attached-deposit '1 NEAR' \
  sign-as <YOUR_ACCOUNT> \
  network-config testnet \
  send
```

## Quick Start

### 🚀 Get Running in 5 Minutes

**Prerequisites**: Complete the [Prerequisites & Setup](#prerequisites--setup) section first to:
- Get NEAR tokens
- Install near-cli-rs
- Create an implicit account
- Purchase a RODiT token

#### Step 1: Install Dependencies

```bash
# Clone the repository
git clone https://github.com/cableguard/timeherenow.git
cd timeherenow

# Install dependencies
npm install

# Create required directories
mkdir -p logs data certs
```

#### Step 2: Configure Credentials

**Option A: Environment Variable (Recommended for Testing)**
```bash
export RODIT_NEAR_CREDENTIALS_SOURCE=env
export NEAR_CREDENTIALS_JSON_B64="<your-base64-encoded-credentials>"
```

Or add to `config/default.json`:
```json
{
  "RODIT_NEAR_CREDENTIALS_SOURCE": "env",
  "NEAR_CREDENTIALS_JSON_B64": "<your-base64-encoded-credentials>"
}
```

**Option B: Vault (Production)**
```bash
export RODIT_NEAR_CREDENTIALS_SOURCE=vault
export VAULT_ENDPOINT=https://vault.example.com
export VAULT_ROLE_ID=your-role-id
export VAULT_SECRET_ID=your-secret-id
export SERVICE_NAME=timeherenow
```

**Option C: File (Development)**
```bash
export RODIT_NEAR_CREDENTIALS_SOURCE=file
export CREDENTIALS_FILE_PATH=./.near-credentials/testnet/your-token.json
```

#### Step 3: Run Examples

```bash
# Run all SDK examples
node src/examples.js

# Or run the full application
npm start
```

The server will:
1. Initialize the SDK
2. Run example demonstrations
3. Start HTTPS server on configured port
4. Listen for webhooks

## SDK Features

This application showcases all features of the `@rodit/rodit-auth-be` SDK:

### 1. Authentication & Authorization
- ✅ RODiT-based mutual authentication
- ✅ JWT token generation and validation
- ✅ Session management with pluggable storage
- ✅ Permission-based route authorization

**Code Example:**
```javascript
const { RoditClient } = require('@rodit/rodit-auth-be');

// Initialize SDK client
const client = await RoditClient.create('client');

// Authenticate with server
const loginResult = await client.login_server();
const token = loginResult.jwt_token;
```

**Related API Endpoints:**
- `POST /api/login` - Authenticate and obtain JWT token
- `POST /api/logout` - Terminate session

### 2. Configuration Management
- ✅ Self-configuring from Vault or files
- ✅ RODiT token metadata access
- ✅ Dynamic rate limiting configuration
- ✅ Permission route parsing

**Code Example:**
```javascript
// Access RODiT configuration
const config = await client.getConfigOwnRodit();
const metadata = config.own_rodit.metadata;

console.log('API Endpoint:', metadata.subjectuniqueidentifier_url);
console.log('Webhook URL:', metadata.webhook_url);
console.log('JWT Duration:', metadata.jwt_duration);
console.log('Max Requests:', metadata.max_requests);

// Parse permissions
const permissions = JSON.parse(metadata.permissioned_routes);
```

### 3. Session Management
- ✅ Active session tracking
- ✅ Multiple storage backends (In-Memory, SQLite, Redis)
- ✅ Automatic session cleanup
- ✅ Token invalidation

**Code Example:**
```javascript
const sessionManager = client.getSessionManager();

// Get active session count
const activeCount = await sessionManager.getActiveSessionCount();

// Manual cleanup
const cleanup = await sessionManager.runManualCleanup();
console.log(`Removed ${cleanup.removedSessionsCount} expired sessions`);
```

**Related API Endpoints:**
- `GET /api/sessions/list_all` - List all sessions (admin)
- `POST /api/sessions/revoke` - Revoke specific session (admin)
- `POST /api/sessions/cleanup` - Clean up expired sessions

### 4. Performance Monitoring
- ✅ Request counting and rate tracking
- ✅ Error rate monitoring
- ✅ Load level assessment
- ✅ System resource metrics

**Code Example:**
```javascript
const performanceService = client.getPerformanceService();
const metrics = performanceService.getMetrics();

console.log('Total Requests:', metrics.requestCount);
console.log('Error Count:', metrics.errorCount);
console.log('Requests/Minute:', metrics.requestsPerMinute);
console.log('Load Level:', metrics.currentLoadLevel);
```

**Related API Endpoints:**
- `GET /api/metrics` - Get performance metrics
- `GET /api/metrics/system` - Get system resource metrics
- `POST /api/metrics/reset` - Reset metrics (admin)

### 5. Structured Logging
- ✅ Winston-based logging
- ✅ Loki integration for centralized logs
- ✅ Context-aware logging
- ✅ Request/response tracking

**Code Example:**
```javascript
const logger = client.getLogger();

// Structured logging
logger.info('Operation completed', {
  component: 'UserService',
  operation: 'createUser',
  userId: '123',
  duration: 150
});

// Context-aware logging
logger.infoWithContext('Request processed', {
  component: 'API',
  method: 'POST',
  path: '/api/users',
  requestId: req.requestId,
  duration: Date.now() - req.startTime
});
```

### 6. Webhook Handling
- ✅ Webhook sending to configured destinations
- ✅ Event payload structuring
- ✅ Error handling and retries
- ✅ Webhook authentication

**Code Example:**
```javascript
// Send webhook
const webhookPayload = {
  event: 'data_created',
  data: {
    id: 123,
    timestamp: new Date().toISOString()
  },
  isError: false
};

const result = await client.send_webhook(webhookPayload, req);
```

**Related API Endpoints:**
- `POST /webhook` - Receive webhooks
- `POST /api/timers/schedule` - Schedule delayed webhooks

## Common Use Cases

### Use Case 1: Basic Authentication

```javascript
const { RoditClient } = require('@rodit/rodit-auth-be');

// Initialize SDK
const client = await RoditClient.create('client');

// Authenticate
const result = await client.login_server();
const token = result.jwt_token;
```

### Use Case 2: Get Current Time

```javascript
// Get time for a timezone
const timeData = await makeAPICall(
  apiEndpoint,
  '/api/timezone/time',
  { timezone: 'America/New_York', locale: 'en-US' },
  token
);

console.log('Current Time:', timeData.date_time);
console.log('Timezone:', timeData.time_zone);
```

### Use Case 3: Schedule Delayed Webhook

```javascript
// Schedule a webhook to fire in 10 seconds
const timer = await makeAPICall(
  apiEndpoint,
  '/api/timers/schedule',
  {
    delay_seconds: 10,
    payload: { message: 'Timer fired!' }
  },
  token
);

console.log('Timer ID:', timer.timer_id);
console.log('Will execute at:', timer.execute_at);
```

### Use Case 4: Session Management

```javascript
const sessionManager = client.getSessionManager();

// Get active session count
const count = await sessionManager.getActiveSessionCount();
console.log('Active sessions:', count);

// Clean up expired sessions
const cleanup = await sessionManager.runManualCleanup();
console.log('Removed:', cleanup.removedSessionsCount);
```

### Use Case 5: Performance Monitoring

```javascript
const perfService = client.getPerformanceService();
const metrics = perfService.getMetrics();

console.log('Total Requests:', metrics.requestCount);
console.log('Errors:', metrics.errorCount);
console.log('Requests/Min:', metrics.requestsPerMinute);
console.log('Load Level:', metrics.currentLoadLevel);
```

## API Endpoints Coverage

This application demonstrates usage of all Time Here Now API endpoints:

### Time Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/timezone` | POST | Authenticated API calls | List all IANA timezones |
| `/api/timezone/area` | POST | Authenticated API calls | List timezones by area |
| `/api/timezone/time` | POST | Authenticated API calls | Get time for timezone |
| `/api/timezones/by-country` | POST | Authenticated API calls | List timezones by country code |
| `/api/ip` | POST | Authenticated API calls | Get time based on IP geolocation |

**Example:**
```javascript
// Get current time for a timezone
const timeData = await makeAPICall(apiEndpoint, '/api/timezone/time', {
  timezone: 'America/New_York',
  locale: 'en-US'
}, token);

console.log('Timezone:', timeData.time_zone);
console.log('Current Time:', timeData.date_time);
console.log('UTC Time:', timeData.utc_datetime);
```

### Cryptographic Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/sign/hash` | POST | Authenticated API calls | Sign hash with NEAR timestamp |

**Example:**
```javascript
const crypto = require('crypto');
const hash = crypto.createHash('sha256').update('data').digest();
const hashB64url = hash.toString('base64url');

const signResult = await makeAPICall(apiEndpoint, '/api/sign/hash', {
  hash_b64url: hashB64url
}, token);

console.log('Timestamp:', signResult.data.timestamp_iso);
console.log('Signature:', signResult.signature_base64url);
```

### Timer Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/timers/schedule` | POST | Webhook handling | Schedule delayed webhook |

**Example:**
```javascript
const timerResult = await makeAPICall(apiEndpoint, '/api/timers/schedule', {
  delay_seconds: 10,
  payload: {
    message: 'Timer fired',
    timestamp: new Date().toISOString()
  }
}, token);

console.log('Timer ID:', timerResult.timer_id);
console.log('Execute At:', timerResult.execute_at);
```

### MCP (Model Context Protocol) Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/mcp/resources` | GET | Authenticated API calls | List available MCP resources |
| `/api/mcp/resource/:uri` | GET | Authenticated API calls | Get specific MCP resource |
| `/api/mcp/schema` | GET | Authenticated API calls | Get MCP OpenAPI schema |

**Example:**
```javascript
const resources = await makeAPICall(apiEndpoint, '/api/mcp/resources', {}, token, 'GET');

resources.resources.forEach(resource => {
  console.log(`${resource.name} (${resource.uri})`);
});
```

### Metrics Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/metrics` | GET | Performance monitoring | Get performance metrics |
| `/api/metrics/system` | GET | Performance monitoring | Get system metrics |
| `/api/metrics/reset` | POST | Performance monitoring | Reset metrics (admin) |
| `/api/metrics/debug` | GET | Performance monitoring | Debug metrics system |

### Session Management Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/sessions/list_all` | GET | Session management | List all active sessions (admin) |
| `/api/sessions/revoke` | POST | Session management | Revoke specific session (admin) |
| `/api/sessions/cleanup` | POST | Session management | Clean up expired sessions |

### Authentication Endpoints

| Endpoint | Method | SDK Feature | Description |
|----------|--------|-------------|-------------|
| `/api/login` | POST | Authentication | Authenticate with RODiT token |
| `/api/logout` | POST | Authentication | Terminate session |
| `/api/signclient` | POST | Portal authentication | Mint new client RODiT token |

**See [api-docs/timeherenow-README.md](api-docs/timeherenow-README.md) for complete API documentation.**

## Running the Examples

### 📚 What You'll See

The examples demonstrate:

1. ✅ **Authentication** - SDK initialization and login
2. ✅ **Configuration** - Accessing RODiT metadata
3. ✅ **API Calls** - Making authenticated requests
4. ✅ **Sessions** - Managing user sessions
5. ✅ **Metrics** - Performance monitoring
6. ✅ **Webhooks** - Sending/receiving webhooks
7. ✅ **Timers** - Delayed webhook scheduling
8. ✅ **IP Lookup** - Geolocation-based time
9. ✅ **Signing** - Cryptographic operations
10. ✅ **Timezones** - Timezone queries
11. ✅ **Logging** - Structured logging
12. ✅ **MCP** - AI resource discovery

### Option 1: Run All Examples

```bash
node src/examples.js
```

This will execute all 12 examples sequentially, demonstrating every SDK feature.

### Option 2: Run Specific Examples

```javascript
const {
  example1_Authentication,
  example2_Configuration,
  example3_AuthenticatedAPICalls
} = require('./src/examples');

(async () => {
  const client = await example1_Authentication();
  await example2_Configuration(client);
  await example3_AuthenticatedAPICalls(client);
})();
```

### Option 3: Run the Full Application

```bash
npm start
```

The application will:
1. **Automatically kill** any existing process on port 3444
2. Initialize the SDK
3. Start HTTPS server on configured port (3444)
4. Run all examples automatically
5. Listen for incoming webhooks

**Note**: The `npm start` command includes a `prestart` script that automatically cleans up port 3444 before starting.

**Manual port cleanup** (if needed):
```bash
# Kill process on port 3444
./scripts/kill-port.sh

# Or specify a different port
./scripts/kill-port.sh 8443

# Or use lsof directly
lsof -ti:3444 | xargs kill -9
```

## Code Examples

### Complete Authentication Flow

```javascript
const express = require('express');
const { RoditClient } = require('@rodit/rodit-auth-be');

const app = express();
app.use(express.json());

let roditClient;

// Initialize SDK
async function init() {
  roditClient = await RoditClient.create('client');
  app.locals.roditClient = roditClient;
  
  // Get logger and middleware
  const logger = roditClient.getLogger();
  const loggingmw = roditClient.getLoggingMiddleware();
  
  app.use(loggingmw);
  
  logger.info('SDK initialized');
}

// Authentication middleware
const authenticate = (req, res, next) => {
  const client = req.app.locals.roditClient;
  return client.authenticate(req, res, next);
};

// Authorization middleware
const authorize = (req, res, next) => {
  const client = req.app.locals.roditClient;
  return client.authorize(req, res, next);
};

// Public endpoint
app.post('/api/login', (req, res) => {
  return roditClient.login_client(req, res);
});

// Protected endpoint
app.get('/api/data', authenticate, (req, res) => {
  res.json({
    message: 'Protected data',
    user: req.user
  });
});

// Protected + authorized endpoint
app.post('/api/admin', authenticate, authorize, (req, res) => {
  res.json({
    message: 'Admin action',
    user: req.user
  });
});

init().then(() => {
  app.listen(3000, () => console.log('Server started'));
});
```

### Session Storage Configuration

```javascript
const express = require('express');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const { RoditClient, setExpressSessionStore } = require('@rodit/rodit-auth-be');

// Configure session storage BEFORE initializing RoditClient
const sessionStore = new SQLiteStore({
  db: 'sessions.db',
  dir: './data',
  table: 'sessions'
});

setExpressSessionStore(sessionStore);

// Now initialize client
const client = await RoditClient.create('server');
```

### Making Authenticated API Calls

```javascript
const https = require('https');

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
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve(JSON.parse(data)));
    });
    
    req.on('error', reject);
    
    if (method === 'POST' && body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

// Usage
const client = await RoditClient.create('client');
const loginResult = await client.login_server();
const config = await client.getConfigOwnRodit();

const timeData = await makeAPICall(
  config.own_rodit.metadata.subjectuniqueidentifier_url,
  '/api/timezone/time',
  { timezone: 'America/New_York' },
  loginResult.jwt_token
);
```

## Best Practices

### 1. SDK Initialization

✅ **DO**: Initialize once and store in `app.locals`
```javascript
const client = await RoditClient.create('client');
app.locals.roditClient = client;
```

❌ **DON'T**: Create multiple instances
```javascript
// Avoid this
const client1 = await RoditClient.create('client');
const client2 = await RoditClient.create('client');
```

### 2. Error Handling

✅ **DO**: Handle errors gracefully
```javascript
try {
  const result = await client.login_server();
  if (result.error) {
    logger.error('Login failed:', result.error);
    return res.status(401).json({ error: result.error });
  }
} catch (error) {
  logger.error('Unexpected error:', error);
  return res.status(500).json({ error: 'Internal server error' });
}
```

### 3. Logging

✅ **DO**: Use structured logging with context
```javascript
logger.info('Operation completed', {
  component: 'UserService',
  operation: 'createUser',
  userId: user.id,
  duration: Date.now() - startTime,
  requestId: req.requestId
});
```

### 4. Session Management

✅ **DO**: Use persistent storage in production
```javascript
// SQLite for single-server
const sessionStore = new SQLiteStore({ db: 'sessions.db' });
setExpressSessionStore(sessionStore);

// Redis for multi-server
const redisStore = new RedisStore({ client: redisClient });
setExpressSessionStore(redisStore);
```

### 5. Webhook Handling

✅ **DO**: Handle webhook failures gracefully
```javascript
try {
  const result = await client.send_webhook(payload, req);
  if (!result.success) {
    logger.warn('Webhook delivery failed', { error: result.error });
  }
} catch (error) {
  // Don't crash the application on webhook failures
  logger.error('Webhook error:', error);
}
```

### 6. Configuration

✅ **DO**: Use environment variables for sensitive data
```bash
export VAULT_ROLE_ID=your-role-id
export VAULT_SECRET_ID=your-secret-id
export LOKI_BASIC_AUTH=username:password
```

❌ **DON'T**: Hardcode credentials
```javascript
// Avoid this
const vaultRoleId = 'hardcoded-role-id';
```

## Project Structure

```
timeherenow-test/
├── config/                    # Configuration files
│   ├── default.json          # Main configuration
│   └── custom-environment-variables.json
├── src/
│   ├── app.js               # Main application (SDK initialization)
│   └── examples.js          # Comprehensive SDK examples
├── api-docs/                # API documentation
│   ├── timeherenow-README.md
│   └── timeherenow-swagger.json
├── sdk/
│   └── README.md            # SDK documentation
├── logs/                    # Application logs
├── data/                    # Database files
├── certs/                   # SSL certificates
└── package.json            # Dependencies
```

## Configuration

### Logging Configuration

The SDK provides comprehensive logging with optional Loki integration:

```bash
# Configure logging
export LOG_LEVEL=info
export LOKI_URL=https://loki.example.com:3100
export LOKI_BASIC_AUTH=username:password
```

Logs include:
- Structured JSON format
- Request/response tracking
- Performance metrics
- Error stack traces
- Context-aware metadata

## Troubleshooting

### 🔧 Common Issues

#### "SDK initialization failed"
- Check your credentials are correct
- Verify `RODIT_NEAR_CREDENTIALS_SOURCE` is set
- Ensure RODiT token is valid and not expired

#### "Authentication failed"
- Verify API endpoint in RODiT metadata
- Check JWT token is being sent in Authorization header
- Ensure session storage is configured correctly
- Check network connectivity

#### "Webhook Not Received"
- Verify webhook URL in RODiT metadata
- Check SSL certificates are valid
- Ensure firewall allows incoming connections

#### "Cannot find module"
- Run `npm install` to install dependencies
- Check Node.js version (requires 20.x+)

#### "Port already in use" (EADDRINUSE)
The application uses port 3444 by default. If you see this error:

```bash
Error: listen EADDRINUSE: address already in use :::3444
```

**Solution 1: Use npm start** (recommended)
```bash
npm start  # Automatically kills existing process on port 3444
```

**Solution 2: Manual cleanup**
```bash
# Kill process on port 3444
./scripts/kill-port.sh

# Or use lsof directly
lsof -ti:3444 | xargs kill -9
```

**Solution 3: Change the port**
Edit your RODiT token metadata to use a different webhook port, or modify the port extraction in `src/app.js`.

#### Permission Errors
```bash
chmod -R 755 logs data certs
chmod +x scripts/*.sh
```

### 💡 Pro Tips

1. **Start with examples.js** - Run it to see all features in action
2. **Check the logs** - Structured logging shows exactly what's happening
3. **Use the SDK docs** - Comprehensive reference in `sdk/README.md`
4. **Explore the API** - All endpoints documented in `api-docs/`
5. **Copy examples** - Each example is self-contained and ready to use

## Additional Resources

- **📖 API Documentation**: [api-docs/timeherenow-README.md](api-docs/timeherenow-README.md)
- **🔧 SDK Documentation**: [sdk/README.md](sdk/README.md)
- **📋 OpenAPI Spec**: [api-docs/timeherenow-swagger.json](api-docs/timeherenow-swagger.json)
- **🌐 Live API Docs**: https://timeherenow.rodit.org/api-docs/
- **📝 RODiT Whitepaper**: https://vaceituno.medium.com/unleashing-the-power-of-public-key-cryptography-with-non-fungible-tokens-513286d47524

## 🌟 Key Features

- **Zero configuration** - SDK auto-configures from Vault or files
- **Production ready** - All examples follow best practices
- **Complete coverage** - Every SDK feature demonstrated (6 major features, 20 API endpoints)
- **Well documented** - Extensive inline comments and guides
- **Easy to adapt** - Copy examples directly into your app

## Support

- **GitHub Issues**: https://github.com/cableguard/timeherenow/issues
- **Contact**: Discernible Inc.

## License

UNLICENSED - Proprietary software by Discernible Inc.

---

**Ready to start?** Run `node src/examples.js` and watch the magic happen! ✨
