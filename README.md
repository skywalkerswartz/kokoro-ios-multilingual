# Kokoro TTS for Swift — Multilingual Fork

> **This is a fork of [mlalma/kokoro-ios](https://github.com/mlalma/kokoro-ios) that adds support for non-English languages.** See [What's Different in This Fork](#whats-different-in-this-fork) below. The intent is to eventually propose these changes back upstream as a pull request.

✨ *New in 1.0.8:* Added timestamps for each token. Please check [Kokoro Test App](https://github.com/mlalma/KokoroTestApp) how to use them.

✨ *New in 1.0.5:* Voice styles are moved out of the library to the integrating application. Please check [Kokoro Test App](https://github.com/mlalma/KokoroTestApp) how to use them.

Kokoro is a high-quality TTS (text-to-speech) model, providing faster than real-time audio generation.

*NOTE:* This is a SPM package of the TTS engine. For an application integrating Kokoro and showing how the neural speech synthesis works, please see [KokoroTestApp](https://github.com/mlalma/KokoroTestApp) project.

Kokoro TTS port is based on the great work done in [MLX-Audio project](https://github.com/Blaizzy/mlx-audio), where the model was ported from PyTorch to MLX Python. This project ports the MLX Python code to MLX Swift.

Currently the library generates audio ~3.3 times faster than real-time on the release build on iPhone 13 Pro after warm up / first run.

## What's Different in This Fork

The upstream library supports only US and British English. This fork adds support for the other languages that the [Kokoro model](https://github.com/hexgrad/kokoro) itself was trained on.

### New Languages

| `Language` case | Code | Language |
|---|---|---|
| `.es` | `es` | Spanish |
| `.frFR` | `fr-fr` | French |
| `.hi` | `hi` | Hindi |
| `.it` | `it` | Italian |
| `.ptBR` | `pt-br` | Brazilian Portuguese |
| `.zh` | `cmn` | Mandarin Chinese |
| `.ja` | `ja` | Japanese |

### Changes Made

- **`Package.swift`** — The `eSpeakNGSwift` dependency (previously commented out) is now enabled. Non-English G2P is handled by eSpeak NG, which already ships with data for all these languages inside its bundled framework.
- **`Language.swift`** — The `Language` enum is extended with the seven new cases above.
- **`eSpeakNGG2PProcessor.swift`** — No changes needed; it already mapped `Language.rawValue` to `eSpeakNGLib.Language` generically.

### G2P Engine Selection

The **Misaki** engine (`.misaki`) handles English only and will throw `unsupportedLanguage` for the new cases — this is unchanged and correct. The **eSpeak NG** engine (`.eSpeakNG`) handles all languages including English.

```swift
// English — either engine works; .misaki is higher quality for English
let tts = KokoroTTS(modelPath: modelURL, g2p: .misaki)
try tts.generateAudio(voice: voice, language: .enUS, text: "Hello world")

// Non-English — must use .eSpeakNG
let tts = KokoroTTS(modelPath: modelURL, g2p: .eSpeakNG)
try tts.generateAudio(voice: voice, language: .es, text: "Hola mundo")
```

### Known Limitations

- Long texts may be truncated for non-English languages. The upstream Kokoro Python project notes that chunking logic is not yet implemented for non-English inputs; splitting text into sentences before passing it in is recommended.
- Japanese and Chinese output quality depends on eSpeak NG's phonemization, which is less accurate than the dedicated `misaki[ja]` / `misaki[zh]` Python packages. Swift ports of those are not yet available.

## Requirements

- iOS 18.0+
- macOS 15.0+
- (Other Apple platforms may work as well)

## Installation

Add KokoroSwift to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/mlalma/kokoro-ios.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "KokoroSwift", package: "kokoro-ios")
    ]
)
```

## Usage

```swift
import KokoroSwift

// Initialize the TTS engine
let modelPath = URL(fileURLWithPath: "path/to/your/model")
let tts = KokoroTTS(modelPath: modelPath, g2p: .misaki)

// Generate speech
let voiceEmbedding = ... // See KokoroTestApp on how to get a voice style as an `MLXArray`
let text = "Hello, this is a test of Kokoro TTS."
let audioBuffer = try tts.generateAudio(voice: voiceEmbedding, language: .enUS, text: text)

// audioBuffer now contains the synthesized speech
```

## G2P (Grapheme-to-Phoneme) Options

- `.misaki` — MisakiSwift; supports English (US and GB) only
- `.eSpeakNG` — eSpeakNG; supports all languages listed above

## Model Files

You'll need to provide your own Kokoro TTS model file due to its large size as well as voice style. Please see example project [Kokoro Test App](https://github.com/mlalma/KokoroTestApp) how they can be included as a part of the application package.

## Dependencies

This package depends on:
- [MLX Swift](https://github.com/ml-explore/mlx-swift) — Apple's MLX framework for Swift
- [MisakiSwift](https://github.com/mlalma/MisakiSwift) — English G2P processor
- [eSpeakNGSwift](https://github.com/skywalkerswartz/eSpeakNGSwift-multilingual) — Multilingual G2P processor (this fork)
- [MLXUtilsLibrary](https://github.com/mlalma/MLXUtilsLibrary) — Utility library

## License

This project is licensed under MIT License - see the [LICENSE](LICENSE) file for details.