#### Quick Reference for Frontend Integration

**Base URL**: `https://api.timeherenow.com`


**Available Endpoints**:

*Public Endpoints (no authentication required):*
- `POST /api/login` - Authentication.
- `POST /api/signclient` - Sign client RODiT token
- `GET /health` - Health check
- `GET /api-docs` - Interactive API documentation (Swagger UI)
- `GET /swagger.json` - Raw OpenAPI specification (JSON)
- `GET /api/mcp/resources` - List available MCP resources (Public for AI discovery)
- `GET /api/mcp/resource/:uri` - Get specific MCP resource (Public for AI discovery)
- `GET /api/mcp/schema` - Get MCP OpenAPI schema (Public for AI discovery)

*Protected Endpoints (require authentication only):*
- `POST /api/logout` - Logout

*Protected Endpoints (require authentication and authorization):*
- `POST /api/timers/schedule` - Schedule delayed webhook (Client RODiT destination)
- `POST /api/timezone` - List all IANA timezones
- `POST /api/timezone/area` - List timezones for a given area
- `POST /api/timezone/time` - Get current time for a timezone (or by client IP)
- `POST /api/timezones/by-country` - List timezones by ISO country code
- `POST /api/ip` - Get current time with location obtained from the IP (IPv4 or IPv6)
- `POST /api/sign/hash` - Sign a hash with NEAR timestamp
- `GET /api/metrics` - Get performance metrics (requires permission)
- `HEAD /api/metrics` - Health probe for metrics endpoint
- `GET /api/metrics/system` - Get system resource metrics (requires permission)
- `HEAD /api/metrics/system` - Health probe for system metrics endpoint
- `POST /api/metrics/reset` - Reset performance metrics (admin only)
- `GET /api/metrics/debug` - Debug metrics system status (admin only)
- `GET /api/sessions/list_all` - List all active sessions (admin only)
- `POST /api/sessions/revoke` - Revoke a specific session (admin only)
- `POST /api/sessions/cleanup` - Clean up expired sessions (admin only)


**Authentication**: Protected endpoints require `Authorization: Bearer <JWT_TOKEN>` header obtained from `/api/login`.

**DateTimeJsonResponse**:
```json
{
  "user_ip": "203.0.113.10",
  "date_time": "2025-10-08T10:57:01.123+02:00",
  "day_of_week": 3,
  "day_of_year": 281,
  "dst_trueorfalse": true,
  "dst_offset": 3600,
  "time_zone": "Europe/Berlin",
  "unix_time": 175,
  "utc_datetime": "2025-10-08T08:57:01.123Z",
  "utc_offset": "+02:00",
  "week_number": 41,
  "raw_offset": 3600,
  "locale": "de-DE",
  "likely_time_difference_ms": 850
}
```
Fields in bold are the canonical set used by clients: `user_ip`, `date_time`, `day_of_week`, `day_of_year`, `dst_trueorfalse`, `dst_offset`, `time_zone`, `unix_time`, `utc_datetime`, `utc_offset`, `week_number`.
`raw_offset` (seconds) and `locale` are also returned for convenience but are not required.

**IANA Time Zone Database (tzdb)**:
#### Time Endpoints

**Note**: All time endpoints require authentication (`Authorization: Bearer <JWT_TOKEN>` header).

- **POST `/api/timezone`**
  - Response: `string[]` of IANA tzdb IDs, e.g., `"Europe/Berlin"`, `"America/Indiana/Knox"`.

- **POST `/api/timezone/area`**
  - Request:
    ```json
    { "area": "America" }
    ```
  - Response: `string[]` of timezones beginning with `"America/"`.

- **POST `/api/timezones/by-country`**
  - Request:
    ```json
    { "country_code": "US" }
    ```
  - Response: `string[]` of timezones for the ISO 3166-1 alpha-2 code.

- **POST `/api/timezone/time`** (preferred) and legacy segmented params
  - Request (preferred):
    ```json
    { "timezone": "Europe/Berlin", "locale": "de-DE" }
    ```
  - Legacy request (supported):
    ```json
    { "area": "America", "location": "Indiana", "region": "Knox", "locale": "en-US" }
    ```
  - Response (DateTimeJsonResponse):
    ```json
    {
      "user_ip": "203.0.113.10",
      "date_time": "2025-10-08T10:57:01.123+02:00",
      "day_of_week": 3,
      "day_of_year": 281,
      "dst_trueorfalse": true,
      "dst_offset": 3600,
      "time_zone": "Europe/Berlin",
      "unix_time": 175, 
      "utc_datetime": "2025-10-08T08:57:01.123Z",
      "utc_offset": "+02:00",
      "week_number": 41,
      "raw_offset": 3600,
      "locale": "de-DE"
    }
    ```
    - Fields in bold are the canonical set used by clients: `user_ip`, `date_time`, `day_of_week`, `day_of_year`, `dst_trueorfalse`, `dst_offset`, `time_zone`, `unix_time`, `utc_datetime`, `utc_offset`, `week_number`.
    - `raw_offset` (seconds) and `locale` are also returned for convenience but are not required.
    - `likely_time_difference_ms` is a conservative (>99% likely) upper bound on the difference between real time and the returned time, given 5 Hz polling and ~0.6 s block time.
  - Errors: returns HTTP 503 if NEAR blockchain time is unavailable.

- **POST `/api/ip`**
  - Request (optional IP; falls back to client IP):
    ```json
    { "ip": "2001:db8::1", "locale": "en-GB" }
    ```
  - Response: DateTimeJsonResponse (same as above), using timezone resolved from the IP.
  - Errors: returns HTTP 503 if NEAR blockchain time is unavailable.

- **POST `/api/sign/hash`**
  - Request:
    ```json
    { "hash_b64url": "base64url-encoded-hash" }
    ```
  - Response:
    ```json
    {
      "data": {
        "hash_b64url": "base64url-encoded-hash",
        "timestamp_iso": "2025-10-08T10:57:01.000Z",
        "likely_time_difference_ms": 850,
        "public_key_base64url": "base64url-encoded-public-key"
      },
      "concatenated": "hash_b64url.timestamp_iso.likely_time_difference_ms.public_key_base64url",
      "signature_base64url": "base64url-encoded-signature"
    }
    ```
  - Errors: returns HTTP 503 if NEAR blockchain time is unavailable.

##### Time zone data sourcing
- Time zones are sourced from the IANA Time Zone Database (tzdb). See `api-docs/swagger.json` `externalDocs` referencing IANA.
- This project uses `@vvo/tzdb` to access tzdb data.
- Update tzdb:
  - `npm run update-tzdata` (uses `scripts/update-tzdata.sh`)
  - Check version/count: `npm run tz:version`

##### NEAR time polling and availability
- The API polls NEAR blockchain time at 5 Hz and serves the most recent cached value to reduce latency and RPC load.
- If NEAR time is unavailable (no cached value), time endpoints return HTTP 503.
- Tuning environment variables:
  - `NEAR_POLL_MS` (default `200`): polling interval in ms
  - `NEAR_BLOCK_MS` (default `600`): expected block interval in ms
  - `NEAR_NET_MARGIN_MS` (default `50`): network jitter margin in ms

#### Getting Started: Purchasing RODiT Tokens

**Purchase RODiT tokens for Time Here Now API at: https://purchase.timeherenow.com**

##### What are RODiT Tokens?

RODiT (Rights Of Data In Transit) tokens are NFTs on the NEAR blockchain that represent API access rights. Authentication between API clients uses Public Key Cryptography (PKC) with a unique approach: ownership of the RODiTs is verified with the NEAR Protocol in real time, and the PKC key pair used is embedded in the RODiT token itself.

Read more: https://vaceituno.medium.com/unleashing-the-power-of-public-key-cryptography-with-non-fungible-tokens-513286d47524

Each RODiT token contains:
- **Authentication credentials** (public/private key pairs)
- **API service configuration** (endpoints, permissions, rate limits)
- **Subscription information** (start date, expiration date)
- **Network access parameters** (IP ranges, ports, bandwidth limits)

##### How to Purchase

**Step 1: Get NEAR Tokens**

Before purchasing RODiT tokens, you need NEAR tokens in your wallet:

- **For Production (Mainnet)**: Purchase NEAR from exchanges like Binance, Coinbase, Kraken, KuCoin, or Gate.io
- **For Testing (Testnet)**: Get free testnet NEAR from https://near-faucet.io/
- **Amount needed**: 0.1-1 NEAR is typically sufficient for testing

**Step 2: Access the Purchase Portal**

1. Navigate to **https://purchase.timeherenow.com**
2. Connect your NEAR wallet (NEAR Wallet, MyNearWallet, Meteor Wallet, etc.)
3. Ensure you're on the correct network (testnet or mainnet)

**Step 3: Configure and Purchase**

1. Browse available API services and pricing
2. Select the Time Here Now API service
3. Choose the number of client RODiTs needed
4. Review configuration parameters (expiration dates, network settings, bandwidth limits)
5. Confirm the transaction in your NEAR wallet
6. Wait for blockchain confirmation (1-2 seconds)

**Step 4: Retrieve Your RODiT Tokens**

After purchase, your RODiT tokens will appear in your wallet. Extract the credentials for API authentication:

```bash
# View your RODiT tokens
near contract call-function as-read-only <CONTRACT_ID> nft_tokens_for_owner \
  json-args '{"account_id": "<YOUR_ACCOUNT>"}' \
  network-config testnet now

# Get specific RODiT metadata
near contract call-function as-read-only <CONTRACT_ID> nft_token \
  json-args '{"token_id": "<TOKEN_ID>"}' \
  network-config testnet now
```

**Step 5: Use Your RODiT Token**

- Extract the private key from your RODiT for authentication
- Configure your API client with the network parameters from the RODiT metadata
- Use the RODiT token in the `/api/login` endpoint to obtain a session JWT

##### Important Security Notes

- **Never expose private keys** in logs or public repositories
- **Use environment variables** or secure vaults for credential storage
- **Monitor expiration dates** and renew RODiT tokens before they expire
- **Verify RODiT ownership** on-chain before each API session

##### For AI Agents: Automated Purchase Flow

1. Ensure wallet is funded with sufficient NEAR (purchase price + ~0.1 NEAR for gas)
2. Use NEAR API or CLI to interact with the RODiT marketplace contract at https://purchase.timeherenow.com
3. Call the purchase/mint function with required parameters
4. Parse the transaction result to extract token IDs
5. Query token metadata to retrieve configuration
6. Store credentials securely in your configuration management system

---

#### RODiT Wallet Management Script

The `scripts/roditwallet.sh` script provides a command-line interface for managing NEAR accounts and RODiT tokens. This script simplifies common operations like creating accounts, viewing RODiT tokens, and transferring tokens between accounts.

##### Prerequisites

- **NEAR CLI**: Install the latest NEAR CLI
  ```bash
  npm install -g near-cli
  ```
- **Environment Variables**: Set the following in your shell environment:
  ```bash
  export BLOCKCHAIN_ENV="testnet"  # or "mainnet"
  export RODITCONTRACTID="your-rodit-contract.near"
  ```

##### Obtaining the Script

The script is located in the repository at `scripts/roditwallet.sh`. Make it executable:

```bash
chmod +x scripts/roditwallet.sh
```

##### Usage

**Get Help**:
```bash
./scripts/roditwallet.sh help
```

**List All Available Accounts**:
```bash
./scripts/roditwallet.sh
```
Displays all accounts found in `~/.near-credentials/$BLOCKCHAIN_ENV/`

**View RODiT Tokens in an Account**:
```bash
./scripts/roditwallet.sh <account_id>
```
Lists all RODiT token IDs owned by the account and displays the account balance.

Example:
```bash
./scripts/roditwallet.sh alice.testnet
```

**View Specific RODiT Token Details**:
```bash
./scripts/roditwallet.sh <account_id> <rodit_token_id>
```
Displays the full metadata for a specific RODiT token.

Example:
```bash
./scripts/roditwallet.sh alice.testnet token_12345
```

**View Account Keys**:
```bash
./scripts/roditwallet.sh <account_id> keys
```
Displays the private key (Base58) and implicit account ID (Hex) for the account.

**⚠️ Security Warning**: Never share your private keys. Store them securely.

**Create a New Account**:
```bash
./scripts/roditwallet.sh genaccount
```
Generates a new uninitialized account. The account is created locally but needs to be initialized on the blockchain with at least 0.01 NEAR.

**Initialize an Account**:
```bash
./scripts/roditwallet.sh <funding_account_id> <uninitialized_account_id> init
```
Initializes a new account by sending 0.01 NEAR from a funded account.

Example:
```bash
./scripts/roditwallet.sh alice.testnet bob.testnet init
```

**Transfer RODiT Between Accounts**:
```bash
./scripts/roditwallet.sh <origin_account_id> <destination_account_id> <rodit_token_id>
```
Transfers a RODiT token from one account to another.

Example:
```bash
./scripts/roditwallet.sh alice.testnet bob.testnet token_12345
```

##### Common Workflows

**Setting Up a New Test Account**:
```bash
# 1. Create a new account
./scripts/roditwallet.sh genaccount
# Output: new_account_123.testnet

# 2. Initialize it with NEAR from an existing account
./scripts/roditwallet.sh existing_account.testnet new_account_123.testnet init

# 3. Verify the account
./scripts/roditwallet.sh new_account_123.testnet
```

**Managing RODiT Tokens**:
```bash
# 1. View all RODiTs in your account
./scripts/roditwallet.sh myaccount.testnet

# 2. View details of a specific RODiT
./scripts/roditwallet.sh myaccount.testnet token_abc123

# 3. Transfer RODiT to another account
./scripts/roditwallet.sh myaccount.testnet recipient.testnet token_abc123
```

##### Script Version

The script displays its version on startup:
```
Version 0.93.53 running on testnet at Smart Contract rodit.testnet
```

##### Troubleshooting

- **"Account does not exist in the blockchain"**: The account needs to be initialized with at least 0.01 NEAR
- **"There is a lag while collecting information"**: Normal behavior when querying the blockchain
- **Environment variables not set**: Ensure `BLOCKCHAIN_ENV` and `RODITCONTRACTID` are exported in your shell

---

#### Authentication Endpoints

##### POST /login
RODiT mutual authentication endpoint for obtaining session tokens using your purchased RODiT credentials.

**Request Body**:
```json
{
  "roditToken": "string"
}
```

**Response (200)**:
```json
{
  "success": true,
  "message": "Authentication successful",
  "user": {
    "id": "string"
  },
  "token": "string"
}
```

##### POST /api/logout
Session termination endpoint.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "success": true,
  "message": "Logout successful"
}
```

#### Signing Endpoints

##### POST /api/signclient
RODiT token minting endpoint for creating new client tokens.

**Request Body**:
```json
{
  "tobesignedValues": {
    "not_after": "string (ISO 8601 timestamp)",
    "max_requests": "number",
    "maxrq_window": "number",
    "permissioned_routes": "string (JSON)",
    "serviceprovider_signature": "string"
  },
  "mintingfee": "string",
  "mintingfeeaccount": "string"
}
```

**Response (201)**:
```json
{
  "token_id": "string",
  "fee_signature_base64url": "string"
}
```

##### POST /api/sign/hash
Sign a base64url-encoded hash concatenated with the latest NEAR timestamp, likely_time_difference_ms, and public key.

**Request Body**:
```json
{
  "hash_b64url": "string (base64url-encoded hash, 1-128 bytes when decoded)"
}
```

**Response (200)**:
```json
{
  "data": {
    "hash_b64url": "string",
    "timestamp_iso": "string (ISO 8601)",
    "likely_time_difference_ms": "number",
    "public_key_base64url": "string"
  },
  "concatenated": "string",
  "signature_base64url": "string"
}
```

**Errors**:
- 400: Invalid hash format or length
- 503: NEAR time unavailable or signing service unavailable

#### Timer Endpoint

##### POST /api/timers/schedule
Schedules a delayed webhook to the SDK-configured destination. Returns a ULID immediately; the same `timer_id` is included in the webhook payload when it fires.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Request Body**:
```json
{ "delay_seconds": 10, "payload": { "any": "json" } }
```

**Constraints**:
- `delay_seconds`: Required, must be between 1 and 172800 (48 hours)
- **Minimum granularity**: 1 second. Sub-second delays are not supported.

**Response (202)**:
```json
{ "timer_id": "01JD8X...", "delay_seconds": 10, "scheduled_at": "ISO", "execute_at": "ISO", "requestId": "01JD8X..." }
```

**Webhook Payload (sent by SDK)**:
```json
{
  "timer_id": "01JD8X...",
  "scheduled_at": "ISO",
  "execute_at": "ISO",
  "fired_at": "ISO",
  "user_id": "string",
  "session_key": "string",
  "payload": { "any": "json" }
}
```

**Blockchain Time Behavior**:
- All timestamps (`scheduled_at`, `execute_at`, `fired_at`) use **NEAR blockchain time** as the exclusive time source
- NEAR blockchain produces blocks at ~500-600ms intervals; timestamps advance in discrete steps, not continuously
- `fired_at` is guaranteed to be >= `execute_at` to maintain temporal consistency
- Due to blockchain time granularity and caching, `fired_at` may equal `execute_at` even when actual delivery occurs later
- For applications requiring sub-second precision, consider the inherent ~600ms granularity of blockchain time

#### MCP (Model Context Protocol) Endpoints

##### GET /api/mcp/resources
List available MCP resources for AI model access.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Query Parameters**:
- `limit` (optional): Maximum number of resources to return
- `cursor` (optional): Pagination cursor

**Response (200)**:
```json
{
  "resources": [
    {
      "uri": "openapi:swagger",
      "name": "OpenAPI Schema",
      "type": "application/json"
    },
    {
      "uri": "config:default",
      "name": "Server Default Config",
      "type": "application/json"
    },
    {
      "uri": "readme:main",
      "name": "README Documentation",
      "type": "text/markdown"
    },
    {
      "uri": "health:status",
      "name": "Health Status with NEAR Blockchain Info",
      "type": "application/json"
    },
    {
      "uri": "guide:api",
      "name": "Comprehensive API Guide",
      "type": "application/json"
    }
  ],
  "nextCursor": null,
  "requestId": "01JD8X..."
}
```

##### GET /api/mcp/resource/:uri
Get a specific MCP resource by URI.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Path Parameters**:
- `uri`: Resource URI (e.g., `openapi:swagger`, `config:default`, `readme:main`, `health:status`, `guide:api`)

**Response (200)**:
```json
{
  "type": "application/json",
  "content": { ... },
  "requestId": "01JD8X..."
}
```

##### GET /api/mcp/schema
Get the OpenAPI schema for the MCP interface.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "openapi": "3.0.1",
  "info": { ... },
  "paths": { ... },
  "requestId": "01JD8X..."
}
```

#### Metrics Endpoints

##### GET /api/metrics
Get current performance metrics including request counts and session information.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "requestCount": 1234,
  "errorCount": 5,
  "requestsPerMinute": 20.5,
  "currentLoadLevel": "low",
  "requests": {
    "total": 1234,
    "errors": 5,
    "perMinute": 20.5
  },
  "sessions": {
    "active": 10,
    "active_count": 10
  },
  "timestamp": "2025-10-24T16:18:00.000Z",
  "requestId": "01JD8X..."
}
```

##### GET /api/metrics/system
Get system resource metrics including CPU, memory, and uptime.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "metrics": {
    "cpu": {
      "usage": 25.5
    },
    "memory": {
      "used": 524288000,
      "total": 2147483648
    },
    "uptime": 86400
  },
  "timestamp": 1729787880000,
  "requestId": "01JD8X..."
}
```

##### HEAD /api/metrics
Health probe for metrics endpoint. Returns 200 OK with no body if the endpoint is available.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**: Empty body

##### HEAD /api/metrics/system
Health probe for system metrics endpoint. Returns 200 OK with no body if the endpoint is available.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**: Empty body

##### POST /api/metrics/reset
Reset performance metrics counters. Requires admin permissions.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "message": "Performance metrics reset successfully",
  "timestamp": 1729787880000,
  "requestId": "01JD8X..."
}
```

**Errors**:
- 403: Permission denied (admin permission required)

##### GET /api/metrics/debug
Debug endpoint to check metrics system status.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "debug": {
    "hasRoditClient": true,
    "clientType": "RoditClient",
    "hasPerformanceService": true,
    "performanceServiceType": "PerformanceService",
    "metricsSnapshot": { ... },
    "timestamp": 1729787880000,
    "requestProcessingTime": 15
  },
  "requestId": "01JD8X..."
}
```

#### Session Management Endpoints

##### GET /api/sessions/list_all
List all active sessions (admin only).

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "sessions": [
    {
      "id": "session_123",
      "roditId": "rodit_456",
      "ownerId": "user_789",
      "createdAt": "2025-10-24T10:00:00.000Z",
      "expiresAt": "2025-10-24T18:00:00.000Z",
      "lastAccessedAt": "2025-10-24T16:00:00.000Z",
      "status": "active"
    }
  ],
  "count": 1,
  "timestamp": "2025-10-24T16:18:00.000Z"
}
```

##### POST /api/sessions/revoke
Revoke a specific session (admin only).

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Request Body**:
```json
{
  "sessionId": "session_123",
  "reason": "admin_termination"
}
```

**Response (200)**:
```json
{
  "message": "Session terminated successfully",
  "sessionId": "session_123",
  "reason": "admin_termination",
  "timestamp": "2025-10-24T16:18:00.000Z"
}
```

##### POST /api/sessions/cleanup
Clean up expired sessions.

**Headers**: `Authorization: Bearer <JWT_TOKEN>`

**Response (200)**:
```json
{
  "success": true,
  "message": "Session cleanup completed",
  "stats": {
    "removedCount": 5,
    "activeSessions": 10,
    "totalSessions": 10
  },
  "requestId": "01JD8X...",
  "timestamp": "2025-10-24T16:18:00.000Z"
}
```

#### System Endpoints

##### GET /health
Health check endpoint for monitoring server status with embedded NEAR RPC status.

**Response (200)**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "service": "Time Here Now API",
  "near": {
    "status": "healthy",
    "endpoint": "https://rpc.mainnet.near.org",
    "timestamp": "2025-10-08T10:57:01.000Z",
    "cache_available": true,
    "last_fetch_timestamp": "2025-10-08T10:57:00.950Z",
    "last_fetch_age_ms": 50,
    "last_block_timestamp": "2025-10-08T10:57:00.400Z",
    "last_block_age_ms": 600,
    "poll_interval_ms": 200,
    "block_interval_ms": 600,
    "network_margin_ms": 50,
    "likely_time_difference_ms": 850
  }
}
```

##### GET /api-docs
Interactive Swagger UI documentation for the API.

##### GET /swagger.json
Raw OpenAPI 3.0.1 specification in JSON format for programmatic access and tooling integration.

**Response (200)**:
```json
{
  "openapi": "3.0.1",
  "info": { "title": "Time Here Now API", "version": "20251023" },
  "paths": { ... }
}
```

The `token_id` fields contain unique identifiers generated by the facial combination generator.

### API Documentation
Complete OpenAPI 3.0.1 specification available at: `api-docs/swagger.json`

**Live Documentation**: Available at `https://timeherenow.rodit.org/api-docs/`

## 6. Configuration and Deployment

### Configuration Files

#### config/default.json - Configuration

**Rate Limiting**

Rate limiting can be enabled or disabled via configuration:

```json
{
  "RATE_LIMITING": {
    "enabled": false,
    "login": { "max": 20, "windowMinutes": 1 },
    "signclient": { "max": 6, "windowMinutes": 1 }
  }
}
```

- **enabled**: Set to `false` to temporarily disable all rate limiting
- **login**: IP-based limits for `/api/login` endpoint (20 req/min)
- **signclient**: IP-based limits for `/api/signclient` endpoint (6 req/min)

User-specific rate limits are read from RODiT token metadata (`max_requests`, `maxrq_window`).

**Automated Permission Map Generation**

The `METHOD_PERMISSION_MAP` is automatically generated from `api-docs/swagger.json` during deployment. This ensures the permission configuration stays in sync with the API specification.

```bash
# Generate permission map from swagger.json
node scripts/generate-permission-map.js

# Validate without updating
node scripts/generate-permission-map.js --validate
```

The map defines which permission scopes are allowed for each API operation:

```json
{
  "METHOD_PERMISSION_MAP": {
    "logout": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "timezone": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "area": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "time": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "by-country": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "ip": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "hash": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "schedule": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "resources": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "metrics": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "system": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "list_all": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "revoke": ["entityAndProperties", "propertiesOnly", "entityOnly"],
    "cleanup": ["entityAndProperties", "propertiesOnly", "entityOnly"]
  }
}
```

**Permission Scopes:**
- `entityAndProperties` - Full access (token prefix: `+`)
- `propertiesOnly` - Properties only (token prefix: `-`)
- `entityOnly` - Entity only (no prefix)

These permissions are validated against the RODiT token's `permissioned_routes` field during API calls.

**Customizing Scopes:** To restrict specific operations, add `x-permission-scopes` to the operation in `swagger.json`:

```json
{
  "/admin/endpoint": {
    "post": {
      "x-permission-scopes": ["entityAndProperties"],
      "security": [{ "bearerAuth": [] }]
    }
  }
}
```

See [scripts/README-generate-permission-map.md](scripts/README-generate-permission-map.md) for details.

### Docker Configuration

#### api.Dockerfile - API Container
- **Base Image**: `node:20-alpine` for lightweight Node.js runtime
- **Security**: Runs as non-root user `nodeuser`
- **Process Manager**: Uses `tini` for proper signal handling
- **Entry Point**: Starts the API server via `src/app.js`

#### nginx/nginx.Dockerfile - Reverse Proxy Container
- **Base Image**: `nginx:mainline-alpine` for latest nginx features
- **Configuration**: Uses custom `nginx/nginx.conf`
- **Security**: Runs as nginx user with restricted permissions

### Nginx Configuration (nginx/nginx.conf)

The nginx reverse proxy provides:

**SSL/TLS Security**:
- TLS 1.2/1.3 protocols only
- Strong cipher suites (ECDHE-based)
- Security headers (X-Content-Type-Options, X-Frame-Options, X-XSS-Protection)

**CORS Configuration**:
- Enabled only for `POST /api/signclient` and only for origin `https://purchase.timeherenow.com`
- Preflight `OPTIONS` handled at the proxy
- Credentials supported for that endpoint

**Proxy Features**:
- WebSocket support for real-time connections
- Request/response logging with detailed format
- Error handling with CORS-compliant responses
- Timeouts: 60s for connect/send/read operations

### GitHub Actions Deployment (.github/workflows/deploy.yml)

**Trigger Events**:
- Push to `main` branch
- Pull requests to `main` branch
- Manual workflow dispatch with options:
  - Commit SHA selection
  - Optional IANA Time Zone Database update

**Deployment Process**:

1. **Setup Phase**:
   - Checkout specified commit
   - Setup Node.js 20 with npm cache
   - Install dependencies

2. **Pre-Deployment Updates** (automated):
   - **Time Zone Database Update** (optional): Updates `@vvo/tzdb` to latest IANA tzdb version
   - **Permission Map Generation**: Automatically generates `METHOD_PERMISSION_MAP` from `swagger.json`

2. **File Transfer**:
   - SSH key installation for secure access
   - Directory creation on target server (`~/timeherenow-app/`)
   - Rsync file transfer (excludes .git, node_modules, logs, data)

3. **Container Deployment**:
   - **Cleanup**: Remove existing pods and images
   - **Pod Creation**: Create `timeherenow-pod` with port 8443 exposed
   - **API Container**: Build and run from `api.Dockerfile`
   - **Nginx Container**: Build and run from `nginx/nginx.Dockerfile`

4. **Environment Variables**:
   - Loki logging configuration
   - RODIT/NEAR blockchain settings
   - HashiCorp Vault authentication
   - Service identification and ports

**Target Environment**:
- **Server**: `174.138.10.2`
- **Domain**: `timeherenow.rodit.org`
- **Container Runtime**: Podman

**Volume Mounts**:
- `/app/logs`: Application logs
- `/app/data`: Persistent application data (includes timer persistence)
- `/app/certs`: SSL certificates (read-only)

## 7. Timer Persistence

The API supports scheduling delayed webhooks with a maximum delay of **48 hours (172800 seconds)**. Timers survive server restarts through automatic persistence.

### How It Works

**Automatic Hourly Saves**:
- Active timers are saved to `data/timers.json` every hour
- Saves are atomic (temp file + rename) to prevent corruption
- Maximum data loss window: 1 hour between saves

**Restoration on Startup**:
1. Loads saved timers from disk
2. Calculates remaining time for each timer
3. **Skips expired timers** (never fires late webhooks)
4. Reschedules active timers with adjusted delays

**Graceful Shutdown**:
- On `SIGTERM` or `SIGINT`, performs final save before exit
- Deployments trigger immediate saves (no data loss)

### Design Decisions

**Why Never Fire Late?**
- Webhooks should fire at scheduled time, not arbitrarily later
- Predictability: timers either fire on time or not at all
- Prevents duplicate/late webhooks from confusing downstream systems

**Why 48 Hours?**
- Persistence reduces risk of longer timers
- Flexibility for next-day scheduling
- Balances resource usage with practical use cases

### File Format

```json
{
  "version": 1,
  "saved_at": "2025-10-24T14:35:00.000Z",
  "timer_count": 3,
  "timers": [
    {
      "timer_id": "01JBEXAMPLE123",
      "session_key": "user-session-key",
      "user_id": "user123",
      "scheduled_at": "2025-10-24T14:00:00.000Z",
      "execute_at": "2025-10-24T16:00:00.000Z",
      "delay_seconds": 7200,
      "payload": { "custom": "data" }
    }
  ]
}
```

### Operational Notes

**Kubernetes/Docker**:
- Mount persistent volume at `/app/data` to preserve timers
- Use `terminationGracePeriodSeconds: 30` for graceful shutdown
- Current implementation: single instance with session affinity

**Monitoring**:
- Logs show save/restore events and skipped timers
- Timer callbacks include `restored: true` flag in metrics

## 8. Automated Permission Map Generation

The `METHOD_PERMISSION_MAP` is automatically generated from `api-docs/swagger.json` during deployment, ensuring permissions stay synchronized with the API specification.

### How It Works

**Operation Name Extraction**:
- Script extracts operation names from API paths (last path segment)
- `/timezone/area` → `area`, `/sessions/list_all` → `list_all`

**Authentication Detection**:
- Only endpoints with `security: [{ "bearerAuth": [] }]` are included
- Public endpoints (`/login`, `/signclient`, `/health`) are automatically excluded

**Default Permission Scopes**:
All operations allow three permission scopes by default:
- `entityAndProperties` - Full access (token prefix: `+`)
- `propertiesOnly` - Properties only (token prefix: `-`)
- `entityOnly` - Entity only (no prefix)

### Usage

```bash
# Generate and update config/default.json
node scripts/generate-permission-map.js

# Validate without updating
node scripts/generate-permission-map.js --validate
```

### Customizing Permissions

Add `x-permission-scopes` to operations in `swagger.json`:

```json
{
  "paths": {
    "/admin/endpoint": {
      "post": {
        "x-permission-scopes": ["entityAndProperties"],
        "security": [{ "bearerAuth": [] }]
      }
    }
  }
}
```

### Workflow

**Adding New Endpoint**:
1. Add to `swagger.json` with `security` field
2. Deploy (script runs automatically)
3. Permission map updates automatically

**Removing Endpoint**:
1. Remove from `swagger.json`
2. Deploy
3. Operation removed from permission map

### Benefits

✅ Single source of truth (swagger.json)  
✅ Automatic synchronization on every deployment  
✅ No manual permission config maintenance  
✅ Validation detects inconsistencies  

See [scripts/README-generate-permission-map.md](scripts/README-generate-permission-map.md) for detailed documentation.

### Security Considerations

1. **Container Security**: Non-root users in all containers
2. **Network Security**: HTTPS-only with strong TLS configuration
3. **CORS Security**: Strict origin whitelist
4. **Secrets Management**: HashiCorp Vault integration
