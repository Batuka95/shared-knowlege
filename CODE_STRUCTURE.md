# Code Structure Map

## Main entry/start file
- **Entry script:** `script.au3`.
- Runtime initialization and startup checks happen in global execution flow after function definitions, including OpenCV/IR startup, version check, and environment checks.
- Main runtime loop starts at `While 1` and drives the bot state machine (`While $BOT_ENABLED`).

## OCR / image recognition module
- **OCR (text extraction):** `IDREAD()` crops images and invokes local Tesseract (`tesseract.exe`) to read the player ID.
- **Image recognition engine:** `IR_STARTUP()` loads AIRL/ImageRecognition native DLLs (`AIRL.dll`, `ImageRecognition.dll`).
- **Template matching loop:** `WAITFINDPIC()` performs repeated screenshot capture + `OPENCVFINDPIC()` matching for UI elements.

## Target selection logic
- **Enemy targeting:** `SELECTCLOSESTENEMY()` analyzes UI colors/pixels and ship slots, then selects/focuses enemy targets.
- **Asteroid targeting:** `SELECTASTEROID()` selects asteroid entries from the overlay/list and confirms lock/approach actions.
- **Navigation filtering:** `SELECTOVERLAY()` switches overlay filters (ships/anomaly) to determine what targets are visible.

## Network/server communication
- **Generic HTTP module:** `_HTTP_GET()`, `_HTTP_POST()`, `_HTTP_UPLOAD()` use WinHTTP COM.
- **Version endpoint:** `CHECKFORNEWVERSION()` queries `http://eve.dru4.ru/currentversion.txt`.
- **Auth endpoint:** `AUTH()` calls `http://eve.dru4.ru/auth.php` and parses status (`demo/free/paid`).
- **External integrations:** Telegram bot API helpers (`_INITBOT`, `_SENDMSG`, polling helpers), Discord webhook senders (`DISCORDSENDMESSAGE`, `DISCORDSENDFILE`).
- **ADB transport channel:** `SENDADB()` wraps `adb.exe` command transport; low-level socket helpers exist (`_ANDROID_CONNECT`, `_ANDROID_SEND`).

## Time/expiry validation
- **Hard expiry gate:** startup date check via `_DateDiff("D", "2025/6/20", _NowCalcDate())`; if expired, startup is blocked and app terminates.
- **Session/runtime cap:** `CHECKOVERALLTIME()` computes time left from `$OVERALLTIMERMAX` and stops bot when exceeded.
- **License/status-based runtime:** `AUTH()` response (`demo/free/paid`) adjusts runtime allowance (`$OVERALLTIMERMAX`).

## Screenshot capture function
- **Primary capture:** `ADBSCREEN()` orchestrates screenshot acquisition and validates resulting BMP size.
- **ADB capture attempt:** `ADBSCREENTRY()` executes `ascreencap` + pulls `screenshot.bmp` from device.
- **Manual saved snapshot:** `MAKESREENSHOT()` creates timestamped screenshot copies.
