#!/usr/bin/env bash
# Downloads the Module 1 scenario media listed in media-manifest.json and converts it
# to web sizes: assets/scene-N.jpg (1280px) and assets/narration-N.mp3.
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d)
python3 -I - "$tmp" <<'PY'
import json, subprocess, sys
tmp = sys.argv[1]
m = json.load(open("media-manifest.json"))
for s in m["scenes"]:
    n = s["n"]
    subprocess.run(["curl", "-fsS", "-o", f"{tmp}/s{n}.png", m["base"] + s["image"]], check=True)
    subprocess.run(["curl", "-fsS", "-o", f"{tmp}/a{n}.wav", m["base"] + s["audio"]], check=True)
    from PIL import Image
    im = Image.open(f"{tmp}/s{n}.png").convert("RGB")
    im.thumbnail((1280, 1280))
    im.save(f"scene-{n}.jpg", quality=82, optimize=True, progressive=True)
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", f"{tmp}/a{n}.wav",
                    "-ac", "1", "-b:a", "64k", f"narration-{n}.mp3"], check=True)
    print("scene", n, "ok")
PY
rm -rf "$tmp"
