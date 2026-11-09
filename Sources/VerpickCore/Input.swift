public enum Input {
  public static func read(_ text: String) throws -> [Entry] {
    let bytes = Array(text.utf8)
    guard !bytes.isEmpty else {
      return []
    }

    var lines: [[UInt8]] = []
    var start = 0
    for index in bytes.indices where bytes[index] == 10 {
      lines.append(Array(bytes[start..<index]))
      start = index + 1
    }
    if start < bytes.count {
      lines.append(Array(bytes[start..<bytes.count]))
    }

    guard lines.count <= Registry.maxLines else {
      throw Failure(1, "input is too long (max \(Registry.maxLines) lines)")
    }

    var entries: [Entry] = []
    for (index, originalLine) in lines.enumerated() {
      var line = originalLine
      if line.last == 13 {
        line.removeLast()
      }

      let words = line.split(whereSeparator: { $0 == 32 || $0 == 9 })
      guard let first = words.first else {
        continue
      }
      if first.first == 35 {
        continue
      }
      guard words.count == 1 else {
        throw Failure(1, "line \(index + 1): expected 1 version")
      }

      let word = String(decoding: first, as: UTF8.self)
      guard let version = Version.parse(word) else {
        throw Failure(1, "line \(index + 1): bad version \(word)")
      }
      entries.append(Entry(line: index + 1, word: word, version: version))
    }
    return entries
  }
}
