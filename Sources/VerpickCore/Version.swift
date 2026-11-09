extension Version {
  public var text: String {
    var result = "\(major).\(minor).\(patch)"
    if let pre {
      result += "-" + pre.joined(separator: ".")
    }
    if let build {
      result += "+" + build
    }
    return result
  }

  public static func parse(_ word: String) -> Version? {
    let bytes = Array(word.utf8)
    guard !bytes.isEmpty else {
      return nil
    }

    let suffixStart = bytes.firstIndex(where: { $0 == 45 || $0 == 43 }) ?? bytes.count
    let core = Array(bytes[..<suffixStart])
    let coreParts = split(core, on: 46)
    guard coreParts.count == 3,
      let major = coreNumber(coreParts[0]),
      let minor = coreNumber(coreParts[1]),
      let patch = coreNumber(coreParts[2])
    else {
      return nil
    }

    var pre: [String]?
    var build: String?
    var index = suffixStart

    if index < bytes.count, bytes[index] == 45 {
      index += 1
      let end = bytes[index...].firstIndex(of: 43) ?? bytes.count
      let identifiers = split(Array(bytes[index..<end]), on: 46)
      guard !identifiers.isEmpty,
        identifiers.allSatisfy({ validIdentifier($0, prerelease: true) })
      else {
        return nil
      }
      pre = identifiers.map { String(decoding: $0, as: UTF8.self) }
      index = end
    }

    if index < bytes.count, bytes[index] == 43 {
      index += 1
      let identifiers = split(Array(bytes[index...]), on: 46)
      guard !identifiers.isEmpty,
        identifiers.allSatisfy({ validIdentifier($0, prerelease: false) })
      else {
        return nil
      }
      build = identifiers.map { String(decoding: $0, as: UTF8.self) }.joined(separator: ".")
      index = bytes.count
    }

    guard index == bytes.count else {
      return nil
    }
    return Version(major, minor, patch, pre: pre, build: build)
  }

  public static func compare(_ a: Version, _ b: Version) -> Int {
    for (left, right) in [(a.major, b.major), (a.minor, b.minor), (a.patch, b.patch)] {
      if left != right {
        return left < right ? -1 : 1
      }
    }

    switch (a.pre, b.pre) {
    case (nil, nil):
      return 0
    case (nil, .some):
      return 1
    case (.some, nil):
      return -1
    case let (.some(left), .some(right)):
      for index in 0..<min(left.count, right.count) {
        let result = compareIdentifier(left[index], right[index])
        if result != 0 {
          return result
        }
      }
      if left.count == right.count {
        return 0
      }
      return left.count < right.count ? -1 : 1
    }
  }

  private static func split(_ bytes: [UInt8], on separator: UInt8) -> [[UInt8]] {
    var parts: [[UInt8]] = []
    var start = 0
    for index in bytes.indices where bytes[index] == separator {
      parts.append(Array(bytes[start..<index]))
      start = index + 1
    }
    parts.append(Array(bytes[start..<bytes.count]))
    return parts
  }

  private static func coreNumber(_ bytes: [UInt8]) -> Int? {
    guard !bytes.isEmpty, bytes.count <= 6,
      bytes.allSatisfy({ $0 >= 48 && $0 <= 57 }),
      bytes.count == 1 || bytes[0] != 48
    else {
      return nil
    }
    guard let value = Int(String(decoding: bytes, as: UTF8.self)), value <= Registry.maxNumber else {
      return nil
    }
    return value
  }

  private static func validIdentifier(_ bytes: [UInt8], prerelease: Bool) -> Bool {
    guard !bytes.isEmpty,
      bytes.allSatisfy({
        ($0 >= 48 && $0 <= 57) || ($0 >= 65 && $0 <= 90) || ($0 >= 97 && $0 <= 122) || $0 == 45
      })
    else {
      return false
    }
    let numeric = bytes.allSatisfy({ $0 >= 48 && $0 <= 57 })
    if numeric {
      guard !prerelease || (bytes.count <= 9 && (bytes.count == 1 || bytes[0] != 48))
      else {
        return false
      }
      if prerelease,
        let number = Int(String(decoding: bytes, as: UTF8.self)),
        number > Registry.maxPreNumber
      {
        return false
      }
    }
    return true
  }

  private static func compareIdentifier(_ left: String, _ right: String) -> Int {
    let leftBytes = Array(left.utf8)
    let rightBytes = Array(right.utf8)
    let leftNumeric = leftBytes.allSatisfy({ $0 >= 48 && $0 <= 57 })
    let rightNumeric = rightBytes.allSatisfy({ $0 >= 48 && $0 <= 57 })

    if leftNumeric, rightNumeric {
      let leftValue = Int(String(decoding: leftBytes, as: UTF8.self)) ?? 0
      let rightValue = Int(String(decoding: rightBytes, as: UTF8.self)) ?? 0
      if leftValue != rightValue {
        return leftValue < rightValue ? -1 : 1
      }
    } else if leftNumeric != rightNumeric {
      return leftNumeric ? -1 : 1
    } else {
      for (a, b) in zip(leftBytes, rightBytes) where a != b {
        return a < b ? -1 : 1
      }
    }

    if leftBytes.count == rightBytes.count {
      return 0
    }
    return leftBytes.count < rightBytes.count ? -1 : 1
  }
}
