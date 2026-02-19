# Phone-home and maintenance analysis of `script.au3`

## Quick verdict
Yes — this script phones home.

It relies on a hard-coded remote service (`eve.dru4.ru`) for licensing/status checks and also uses Telegram APIs for remote control/alerts when configured.

Given your note that the original owner passed and the project is abandonware, this behavior can absolutely break the bot if that server is gone or returns unexpected responses.

---

## Confirmed outbound dependencies

### 1) Owner server (`eve.dru4.ru`)
The script sends HTTP requests to:

1. `http://eve.dru4.ru/currentversion.txt` (update/version check)
2. `http://eve.dru4.ru/auth.php` (auth / entitlement / mode selection)
3. `http://eve.dru4.ru/upload.php` (uploads screenshot in registration flow)
4. `http://eve.dru4.ru/stat.php` (stats ping)

### 2) Telegram API (optional but integrated)
The script also talks to:

- `https://api.telegram.org/bot...`

This is used for message sending, screenshot sending, and command polling (`Screenshot`, `DockNstop`, `start`) if token/chat ID are set.

---

## What data is sent

### `auth.php` request payload (query string)
The URL built by `AUTH()` includes:

- `id=` MD5 hash of local `USERID`
- `ver=` script revision
- `asteroid_wiped=` delta (if changed)
- `miner_size=` inferred miner type/size
- `time_for_cycle=` cycle timing metric
- `isk_for_cycle=` income metric

If reply contains `not registered`, it additionally sends:

- `auth.php?nick=<USERID>`
- file upload to `upload.php` with:
  - form field `userid=<USERID>`
  - file `screenshot\nick.png`

### `stat.php`
Sends:

- `id=<MD5(USERID)>`
- `ver=<REV>`

### Telegram side
- Outbound status messages and screenshots to configured chat.
- Polls inbound bot commands from Telegram.

---

## Why it likely appears broken now

If `eve.dru4.ru` is unavailable, DNS-dead, or returns changed responses, these flows can fail:

- startup version checks
- mode assignment (`free/paid/demo`)
- registration fallback/upload
- periodic stat send

In short: **yes, this likely depended on a live server component**.

---

## Recommended maintenance strategy (practical)

## Phase 1: Stabilize immediately (no major rewrite)

1. Disable remote dependency in code paths first:
   - short-circuit `CHECKFORNEWVERSION()`
   - short-circuit `AUTH()` to set a deterministic local mode (for example `free`)
   - make `SENDSTAT()` a no-op

2. Keep Telegram optional:
   - if no token/chat id in config, skip `_INITBOT()` and polling/sending
   - avoid fatal behavior when Telegram is unreachable

3. Add robust defaults:
   - treat any HTTP failure as non-fatal
   - never block bot core loop on remote responses

This gets you an offline-capable baseline quickly.

## Phase 2: Preserve behavior with a local replacement service

If you want legacy behavior without editing too much bot logic, stand up a tiny local service and repoint hostnames/URLs:

- host endpoints compatible with:
  - `/currentversion.txt`
  - `/auth.php`
  - `/upload.php`
  - `/stat.php`
- return minimal expected response tokens (`free`, `paid`, or `not registered`) so existing string checks still work.

You can implement this with a lightweight PHP/Python service and either:

- edit URLs in script to `http://127.0.0.1:<port>/...`, or
- map `eve.dru4.ru` to local IP in hosts/DNS for drop-in compatibility.

## Phase 3: Refactor for maintainability

Introduce a single abstraction layer for network calls:

- `ServerClient_GetVersion()`
- `ServerClient_Auth()`
- `ServerClient_SendStat()`
- `ServerClient_UploadNick()`

Then provide two implementations:

- `OfflineClient` (always local deterministic values)
- `HttpClient` (legacy online behavior)

Switch via config flag (`server_mode=offline|online|local-mock`).

This prevents future lock-in to a dead endpoint.

---

## Security notes

- `eve.dru4.ru` traffic is plain HTTP, not HTTPS.
- Telemetry and identifiers are observable/modifiable on-path.
- If you keep any network mode, prefer HTTPS and signed responses.

---

## If you want, next patch I can provide

I can do a focused code patch that:

1. Forces offline mode by default.
2. Converts `AUTH`, `SENDSTAT`, and version check to safe local behavior.
3. Makes Telegram non-fatal (disabled when unset/unreachable).
4. Adds an INI switch so you can re-enable remote mode later.

That is usually the fastest path to make abandonware like this usable again.

## Implemented in this patch

The script has now been patched for maintainability/offline resilience:

- Added `Settings -> EnableRemoteServer` flag (default `0`) so remote server calls can be disabled without code edits.
- `CHECKFORNEWVERSION()`, `AUTH()`, and `SENDSTAT()` now short-circuit safely when remote mode is disabled.
- Telegram behavior is now guarded by runtime checks so missing token/chat settings do not trigger bot API calls.
- Startup Telegram initialization and direct `_SENDMSG` calls in the main loop are now conditional on Telegram being enabled.

This should let the core bot logic run without requiring the original `eve.dru4.ru` backend.


## Endpoint contract you can host yourself

If you want to migrate away from `eve.dru4.ru` but keep behavior, implement these endpoints on your new host:

1. `GET /currentversion.txt`
   - Response body: plain text version string used by `CHECKFORNEWVERSION()` (example: `1.0.1.16`).

2. `GET /auth.php`
   - Called as:
     - `?id=<md5_user_id>&ver=<rev>&asteroid_wiped=<n>&miner_size=<n>&time_for_cycle=<n>&isk_for_cycle=<n>`
     - or fallback `?nick=<user_id>`
   - Expected response patterns:
     - contains `free` -> bot sets free mode
     - contains `paid` (optionally with number) -> bot sets paid mode and parses number
     - contains `not registered` -> bot triggers nick flow + screenshot upload

3. `POST /upload.php` (multipart/form-data)
   - Field `fileToUpload`: file payload (`screenshot\\nick.png`)
   - Field `userid`: plain user id value
   - Response body is only logged; no strict parsing.

4. `GET /stat.php`
   - Called as: `?id=<md5_user_id>&ver=<rev>`
   - Response body is not used for control flow (just sent/logged).

## New migration setting in code

You can now repoint all of the above without editing code by setting:

- `[Settings] EnableRemoteServer=1`
- `[Settings] RemoteServerBaseUrl=http://your-new-host`

When `EnableRemoteServer=0`, the script runs in offline-safe mode and skips remote calls.
