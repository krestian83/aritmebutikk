import 'dart:math';
import 'dart:typed_data';

/// Builds WAV audio data in memory using pure Dart math.
///
/// All sounds are generated programmatically - no asset files needed.
class WavBuilder {
  static const int _sampleRate = 44100;
  static const int _bitsPerSample = 16;
  static const int _numChannels = 1;

  /// Generates a sine wave tone.
  static Uint8List sineWave({
    required double frequency,
    required double durationMs,
    double volume = 0.5,
    double attackMs = 5,
    double decayMs = 20,
  }) {
    final numSamples = (durationMs / 1000.0 * _sampleRate).round();
    final samples = Float64List(numSamples);

    for (var i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;
      final tMs = t * 1000;

      // ADSR envelope.
      double envelope = 1.0;
      if (tMs < attackMs) {
        envelope = tMs / attackMs;
      } else if (tMs > durationMs - decayMs) {
        envelope = (durationMs - tMs) / decayMs;
      }
      envelope = envelope.clamp(0.0, 1.0);

      samples[i] = sin(2 * pi * frequency * t) * volume * envelope;
    }

    return _encode(samples);
  }

  /// Generates a sawtooth wave tone (buzzy sound).
  static Uint8List sawtoothWave({
    required double frequency,
    required double durationMs,
    double volume = 0.3,
    double decayMs = 50,
  }) {
    final numSamples = (durationMs / 1000.0 * _sampleRate).round();
    final samples = Float64List(numSamples);

    for (var i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;
      final tMs = t * 1000;

      // Quick decay envelope.
      double envelope = 1.0;
      if (tMs < 5) {
        envelope = tMs / 5;
      } else {
        envelope = max(0, 1.0 - tMs / decayMs);
      }

      final phase = (t * frequency) % 1.0;
      samples[i] = (2 * phase - 1) * volume * envelope;
    }

    return _encode(samples);
  }

  /// Concatenates multiple WAV sample buffers sequentially.
  static Uint8List concatenate(List<Uint8List> wavBuffers) {
    // Decode each WAV to raw samples, concatenate, re-encode.
    final allSamples = <double>[];
    for (final wav in wavBuffers) {
      final samples = _decodeSamples(wav);
      allSamples.addAll(samples);
    }
    return _encode(Float64List.fromList(allSamples));
  }

  static List<double> _decodeSamples(Uint8List wav) {
    // Skip 44-byte WAV header, read 16-bit PCM samples.
    const headerSize = 44;
    final data = ByteData.sublistView(wav, headerSize);
    final numSamples = data.lengthInBytes ~/ 2;
    final samples = <double>[];
    for (var i = 0; i < numSamples; i++) {
      final value = data.getInt16(i * 2, Endian.little);
      samples.add(value / 32767.0);
    }
    return samples;
  }

  /// Encodes float samples (-1.0 to 1.0) into a WAV file.
  static Uint8List _encode(Float64List samples) {
    final dataSize = samples.length * (_bitsPerSample ~/ 8);
    final fileSize = 44 + dataSize;
    final buffer = Uint8List(fileSize);
    final data = ByteData.sublistView(buffer);

    // RIFF header.
    buffer[0] = 0x52; // R
    buffer[1] = 0x49; // I
    buffer[2] = 0x46; // F
    buffer[3] = 0x46; // F
    data.setUint32(4, fileSize - 8, Endian.little);
    buffer[8] = 0x57; // W
    buffer[9] = 0x41; // A
    buffer[10] = 0x56; // V
    buffer[11] = 0x45; // E

    // fmt subchunk.
    buffer[12] = 0x66; // f
    buffer[13] = 0x6D; // m
    buffer[14] = 0x74; // t
    buffer[15] = 0x20; // (space)
    data.setUint32(16, 16, Endian.little); // Subchunk1Size
    data.setUint16(20, 1, Endian.little); // PCM format
    data.setUint16(22, _numChannels, Endian.little);
    data.setUint32(24, _sampleRate, Endian.little);
    data.setUint32(
      28,
      _sampleRate * _numChannels * (_bitsPerSample ~/ 8),
      Endian.little,
    ); // ByteRate
    data.setUint16(
      32,
      _numChannels * (_bitsPerSample ~/ 8),
      Endian.little,
    ); // BlockAlign
    data.setUint16(34, _bitsPerSample, Endian.little);

    // data subchunk.
    buffer[36] = 0x64; // d
    buffer[37] = 0x61; // a
    buffer[38] = 0x74; // t
    buffer[39] = 0x61; // a
    data.setUint32(40, dataSize, Endian.little);

    // Write PCM samples.
    for (var i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final intSample = (clamped * 32767).round();
      data.setInt16(44 + i * 2, intSample, Endian.little);
    }

    return buffer;
  }
}
