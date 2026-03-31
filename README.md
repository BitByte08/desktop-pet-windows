# 🐾 Desktop Pet

A lightweight, native macOS desktop overlay app for Apple Silicon Macs.  
Import a GIF, APNG, PNG sequence, or video — it floats on your screen, loops forever, and stays visible across all Spaces.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Optimized-green)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## ⬇️ 다운로드 및 설치

### 방법 1 — Homebrew (권장)

[Homebrew](https://brew.sh)가 설치되어 있다면 아래 명령어 한 줄로 설치할 수 있습니다:

```bash
brew tap bssm-oss/desktop-pet https://github.com/bssm-oss/desktop-pet.git
brew install --cask bssm-oss/desktop-pet/desktop-pet
```

업데이트:

```bash
brew upgrade --cask desktop-pet
```

삭제:

```bash
brew uninstall --cask desktop-pet
```

> **Homebrew가 없다면:** [brew.sh](https://brew.sh)에서 먼저 설치하세요.  
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

---

### 방법 2 — 릴리즈에서 직접 다운로드

1. 이 페이지 오른쪽 **[Releases](https://github.com/bssm-oss/desktop-pet/releases)** 클릭
2. 최신 버전의 **`DesktopPet.dmg`** 다운로드
3. DMG 파일 열기
4. `DesktopPet.app`을 **응용 프로그램(Applications)** 폴더로 드래그
5. 응용 프로그램 폴더에서 실행

> **처음 실행 시 경고가 뜨는 경우:**  
> macOS 보안 정책으로 인해 "개발자를 확인할 수 없음" 경고가 뜰 수 있습니다.  
> **시스템 설정 → 개인 정보 보호 및 보안 → "확인 없이 열기"** 를 클릭하면 됩니다.  
> 또는 터미널에서: `xattr -cr /Applications/DesktopPet.app`

---

### 방법 3 — 소스에서 직접 빌드

요구사항: macOS 14+, Xcode Command Line Tools (`xcode-select --install`)

```bash
git clone https://github.com/bssm-oss/desktop-pet.git
cd desktop-pet

SDK=$(xcrun --sdk macosx --show-sdk-path)
mkdir -p build/DesktopPet.app/Contents/MacOS

swiftc \
  -sdk "$SDK" \
  -target arm64-apple-macosx14.0 \
  -O \
  -framework AppKit -framework AVFoundation \
  -framework CoreGraphics -framework ServiceManagement \
  DesktopPet/App/main.swift \
  DesktopPet/App/AppDelegate.swift \
  DesktopPet/Settings/AppSettings.swift \
  DesktopPet/Settings/SettingsView.swift \
  DesktopPet/Playback/FrameSequence.swift \
  DesktopPet/Playback/GIFDecoder.swift \
  DesktopPet/Playback/APNGDecoder.swift \
  DesktopPet/Playback/PNGSequenceDecoder.swift \
  DesktopPet/Playback/AnimationPlayer.swift \
  DesktopPet/Playback/VideoPlayer.swift \
  DesktopPet/Utilities/PlaceholderAnimation.swift \
  DesktopPet/Utilities/SecurityScopedAccess.swift \
  DesktopPet/Window/OverlayWindow.swift \
  DesktopPet/Window/PetView.swift \
  DesktopPet/Window/OverlayWindowController.swift \
  DesktopPet/MenuBar/MenuBarController.swift \
  -o build/DesktopPet.app/Contents/MacOS/DesktopPet

cp DesktopPet/App/Info.plist build/DesktopPet.app/Contents/Info.plist
open build/DesktopPet.app
```

Xcode가 있다면:

```bash
open DesktopPet.xcodeproj
```

Xcode에서:
1. `DesktopPet` 스킴 선택
2. **Signing & Capabilities** → Team 설정 (Apple ID)
3. `⌘R` 로 빌드 및 실행

---

## 실행 후 사용법

앱을 실행하면 독(Dock)에는 아이콘이 나타나지 않고, **메뉴바에 🐾 아이콘**이 생깁니다.

### 애니메이션 불러오기

| 방법 | 설명 |
|------|------|
| 드래그 앤 드롭 | 파일을 화면의 캐릭터 위로 드래그 |
| 파일 선택 | 🐾 클릭 → "애니메이션 열기…" |
| PNG 시퀀스 | 프레임 PNG가 들어있는 폴더 선택 |

### 조작

| 동작 | 방법 |
|------|------|
| 위치 이동 | 캐릭터를 클릭하고 드래그 |
| 설정 열기 | 🐾 왼쪽 클릭 |
| 빠른 토글 | 🐾 오른쪽 클릭 |
| 재생 / 일시정지 | 설정 패널 또는 오른쪽 클릭 메뉴 |
| 투명도 조절 | 설정 패널 슬라이더 |
| 크기 조절 | 설정 패널 슬라이더 |
| 재생 속도 | 설정 패널 슬라이더 |
| 클릭 통과 | 설정 토글 — 켜면 클릭이 아래 창으로 통과 |
| 위치 잠금 | 설정 토글 — 실수로 움직이는 것 방지 |
| 항상 위에 표시 | 설정 토글 |
| 로그인 시 자동 시작 | 설정 패널 토글 |

---

## 지원 파일 형식

| 형식 | 투명 배경 | 비고 |
|------|----------|------|
| GIF | ✅ | 투명도 완전 지원 |
| APNG | ✅ | macOS 14 네이티브 지원 |
| PNG 시퀀스 (폴더) | ✅ | 파일명 순 정렬, 기본 24fps |
| MP4 / MOV (H.264/H.265) | ❌ | 투명 배경 없음 |
| ProRes 4444 (.mov) | ✅ | 투명 비디오, 하드웨어 디코딩 |
| HEVC with Alpha (.mov) | ✅ | macOS 13+, 작은 파일 크기 |

> MP4 파일은 투명 배경을 지원하지 않습니다. 투명한 캐릭터 오버레이를 원하면 GIF, APNG, PNG 시퀀스를 사용하세요.

---

## What it does

- Displays any animation or video as a **transparent floating overlay** above your desktop
- Stays visible when you **switch Spaces or use fullscreen apps**
- Lives in the **menubar** — no dock icon, no clutter
- Extremely **lightweight**: CVDisplayLink scheduling, GPU-composited CALayer rendering, hardware-decoded media
- Remembers your last position, scale, opacity, speed, and asset across restarts

---

## Project structure

```
DesktopPet/
├── App/                    # AppDelegate, main.swift, Info.plist
├── Window/                 # OverlayWindow, PetView, OverlayWindowController
├── Playback/               # AnimationPlayer, decoders, FrameSequence, VideoPlayer
├── MenuBar/                # MenuBarController
├── Settings/               # AppSettings, SettingsView
└── Utilities/              # PlaceholderAnimation, SecurityScopedAccess
Casks/
└── desktop-pet.rb          # Homebrew Cask formula
```

---

## Docs

- [Architecture](docs/architecture.md)
- [Build & Run](docs/build-and-run.md)
- [Supported Formats](docs/formats.md)
- [Performance](docs/performance.md)
- [Troubleshooting](docs/troubleshooting.md)

---

## Performance

- **CVDisplayLink** — display-sync, ProMotion-aware, sleeps between frames
- **CALayer.contents** — zero-copy GPU upload, no CPU pixel blitting
- **ImageIO** — hardware-backed decode on Apple Silicon
- **AVFoundation** — hardware video decode via Media Engine

Typical CPU usage at steady state: **< 1%** on M-series chips.

---

## License

MIT — see [LICENSE](LICENSE)
