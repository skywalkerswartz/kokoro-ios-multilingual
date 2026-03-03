// KokoroSwift

#if canImport(MisakiSwift) && canImport(eSpeakNGLib)
import Foundation

/// A G2P processor that routes to the best available engine per language:
/// - English (enUS, enGB): Misaki — designed for Kokoro, highest quality
/// - All other languages:  eSpeak NG — broad language support via IPA + E2M
///
/// This lets a single KokoroTTS instance (and its ~1.5 GB of model weights)
/// synthesize any supported language without keeping two model copies in memory.
final class HybridG2PProcessor: G2PProcessor {
  private let misaki = MisakiG2PProcessor()
  private let espeak = eSpeakNGG2PProcessor()
  private var activeProcessor: (any G2PProcessor)?

  func setLanguage(_ language: Language) throws {
    switch language {
    case .enUS, .enGB:
      try misaki.setLanguage(language)
      activeProcessor = misaki
    default:
      try espeak.setLanguage(language)
      activeProcessor = espeak
    }
  }

  func process(input: String) throws -> (String, [MToken]?) {
    guard let active = activeProcessor else {
      throw G2PProcessorError.processorNotInitialized
    }
    return try active.process(input: input)
  }
}
#endif
