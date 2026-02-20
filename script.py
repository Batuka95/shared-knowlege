#!/usr/bin/env python3
"""Python port scaffold for the original AutoIt bot.

This focuses on local automation only (ADB + image matching + control loop).
All remote/phone-home features from `script.au3` are intentionally excluded.
"""

from __future__ import annotations

import argparse
import configparser
import logging
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Tuple

try:
    import cv2  # type: ignore
except Exception:  # optional dependency
    cv2 = None


@dataclass
class BotSettings:
    click_type: int = 4
    screenshoting_type: int = 0
    check_other_ships: bool = False
    need_check_local: bool = False
    fast_mining: bool = True


class ConfigLoader:
    """Loads settings from `eve/conf.ini` into a typed object."""

    @staticmethod
    def load(path: Path) -> BotSettings:
        parser = configparser.ConfigParser()
        parser.read(path, encoding="utf-8")

        settings = parser["Settings"] if parser.has_section("Settings") else {}
        waxtep = parser["Waxtep`s parameters"] if parser.has_section("Waxtep`s parameters") else {}

        return BotSettings(
            click_type=int(settings.get("ClickType", 4)),
            screenshoting_type=int(settings.get("ScreenshotingType", 0)),
            check_other_ships=bool(int(waxtep.get("CheckOtherShips", 0))),
            need_check_local=bool(int(waxtep.get("NeedCheckLocal", 0))),
            fast_mining=bool(int(waxtep.get("FastMining", 1))),
        )


class AdbClient:
    def __init__(self, adb_path: Path, serial: Optional[str] = None) -> None:
        self.adb_path = adb_path
        self.serial = serial

    def _run(self, *args: str, timeout: int = 20) -> str:
        cmd = [str(self.adb_path)]
        if self.serial:
            cmd.extend(["-s", self.serial])
        cmd.extend(args)
        proc = subprocess.run(cmd, check=False, capture_output=True, text=True, timeout=timeout)
        if proc.returncode != 0:
            raise RuntimeError(f"ADB failed: {' '.join(cmd)}\n{proc.stderr.strip()}")
        return proc.stdout.strip()

    def tap(self, x: int, y: int) -> None:
        self._run("shell", "input", "tap", str(x), str(y))

    def swipe(self, x1: int, y1: int, x2: int, y2: int, duration_ms: int = 250) -> None:
        self._run("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration_ms))

    def screencap(self, local_path: Path) -> Path:
        local_path.parent.mkdir(parents=True, exist_ok=True)
        with local_path.open("wb") as fp:
            proc = subprocess.run(
                [str(self.adb_path), *( ["-s", self.serial] if self.serial else []), "exec-out", "screencap", "-p"],
                check=False,
                stdout=fp,
                stderr=subprocess.PIPE,
            )
        if proc.returncode != 0:
            raise RuntimeError(f"ADB screencap failed: {proc.stderr.decode(errors='ignore')}")
        return local_path


class Vision:
    def __init__(self, threshold: float = 0.82) -> None:
        self.threshold = threshold

    def find_template(self, haystack: Path, needle: Path) -> Optional[Tuple[int, int, float]]:
        if cv2 is None:
            raise RuntimeError("opencv-python is required for template matching")
        screen = cv2.imread(str(haystack), cv2.IMREAD_COLOR)
        template = cv2.imread(str(needle), cv2.IMREAD_COLOR)
        if screen is None or template is None:
            return None
        result = cv2.matchTemplate(screen, template, cv2.TM_CCOEFF_NORMED)
        _, max_val, _, max_loc = cv2.minMaxLoc(result)
        if max_val < self.threshold:
            return None
        h, w = template.shape[:2]
        center = (max_loc[0] + w // 2, max_loc[1] + h // 2)
        return center[0], center[1], float(max_val)


class EveBot:
    """Local-only runtime loop.

    Deliberately omitted from the AutoIt source:
    - version/update checks
    - website auth/stat uploads
    - Discord/Telegram notifications
    """

    def __init__(self, adb: AdbClient, settings: BotSettings, image_root: Path, screenshot_path: Path) -> None:
        self.adb = adb
        self.settings = settings
        self.image_root = image_root
        self.screenshot_path = screenshot_path
        self.vision = Vision()

    def click_template(self, relative_image: str) -> bool:
        target = self.image_root / relative_image
        self.adb.screencap(self.screenshot_path)
        match = self.vision.find_template(self.screenshot_path, target)
        if not match:
            return False
        x, y, conf = match
        logging.info("Matched %s at (%s,%s) confidence=%.3f", relative_image, x, y, conf)
        self.adb.tap(x, y)
        return True

    def run_once(self) -> None:
        # Basic equivalent of repeated GUI-driven actions from AutoIt loop.
        if self.click_template("start_mining.bmp"):
            return
        if self.click_template("approach.bmp"):
            return
        logging.info("No known action template found this cycle.")

    def run_forever(self, delay_sec: float = 1.0) -> None:
        while True:
            try:
                self.run_once()
            except Exception:
                logging.exception("Cycle failed")
            time.sleep(delay_sec)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Python runtime for the converted local AutoIt bot.")
    parser.add_argument("--conf", default="eve/conf.ini", help="Path to conf.ini")
    parser.add_argument("--adb", default="eve/adb/adb.exe", help="Path to adb binary")
    parser.add_argument("--serial", default=None, help="ADB device serial")
    parser.add_argument("--images", default="eve/img", help="Image root folder")
    parser.add_argument("--screenshot", default="screenshot/screenshot.png", help="Runtime screenshot path")
    parser.add_argument("--once", action="store_true", help="Run one cycle and exit")
    parser.add_argument("--delay", type=float, default=1.2, help="Delay between cycles")
    parser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"])
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level), format="%(asctime)s %(levelname)s %(message)s")

    settings = ConfigLoader.load(Path(args.conf))
    logging.info("Loaded config: %s", settings)

    adb = AdbClient(Path(args.adb), serial=args.serial)
    bot = EveBot(adb, settings, Path(args.images), Path(args.screenshot))

    if args.once:
        bot.run_once()
    else:
        bot.run_forever(delay_sec=args.delay)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
