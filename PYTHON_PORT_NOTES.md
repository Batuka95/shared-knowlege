# Python port notes

`script.py` is a local-only Python port scaffold of the AutoIt runtime in `script.au3`.

## Included
- ADB command execution (`tap`, `swipe`, `screencap`).
- `conf.ini` parsing for local runtime options.
- Template matching action loop using OpenCV.

## Explicitly excluded (phone-home systems)
- Version/update checks against remote endpoints.
- Auth/stat uploads.
- Discord/Telegram outbound messaging and file upload.

## Quick start
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python script.py --once --log-level DEBUG
```
