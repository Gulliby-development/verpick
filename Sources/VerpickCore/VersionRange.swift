/// A parsed range, retaining each disjunct's own prerelease admission rules.
public struct VersionRange {
  private enum Relation {
    case less
    case lessOrEqual
    case equal
    case greaterOrEqual
    case greater
  }

  private struct Comparison {
    var relation: Relation
    var version: Version

    func accepts(_ candidate: Version) -> Bool {
      let order = Version.compare(candidate, version)
      switch relation {
      case .less: return order < 0
      case .lessOrEqual: return order <= 0
      case .equal: return order == 0
      case .greaterOrEqual: return order >= 0
      case .greater: return order > 0
      }
    }
  }

  private struct SetRule {
    var comparisons: [Comparison]
    var prereleaseTriples: [(Int, Int, Int)]
    var universalReleaseOnly: Bool
  }

  private struct Partial {
    var version: Version
    var precision: Int
    var wildcardFirst: Bool
    var whole: Bool
  }

  private var sets: [SetRule]

  public init(_ text: String) throws {
    let bytes = Array(text.utf8)
    let disjuncts = Self.split(bytes, on: [124, 124])
    var parsed: [SetRule] = []
    do {
      for disjunct in disjuncts {
        parsed.append(try Self.parseSet(disjunct))
      }
    } catch {
      throw Failure(2, "bad range \(text)")
    }
    sets = parsed
  }

  public func contains(_ version: Version, pre: Bool) -> Bool {
    sets.contains { rule in

      guard rule.comparisons.allSatisfy({ $0.accepts(version) }) else {
        return false
      }
      guard version.pre != nil, !pre else {
        return true
      }
      return rule.prereleaseTriples.contains {
        $0.0 == version.major && $0.1 == version.minor && $0.2 == version.patch
      }
    }
  }

  private static func parseSet(_ bytes: [UInt8]) throws -> SetRule {
    let words = tokens(bytes)
    guard !words.isEmpty else { throw Failure(2, "bad") }
    if words.contains([45]) {
      guard words.count == 3, words[1] == [45],
        let left = tryPartial(words[0]), let right = tryPartial(words[2]),
        !left.wildcardFirst, !right.wildcardFirst
      else { throw Failure(2, "bad") }
      var rule = SetRule(comparisons: [], prereleaseTriples: [], universalReleaseOnly: false)
      rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: left.version))
      if let triple = triple(left) { rule.prereleaseTriples.append(triple) }
      if right.whole {
        rule.comparisons.append(Comparison(relation: .lessOrEqual, version: right.version))
      } else {
        rule.comparisons.append(Comparison(relation: .less, version: upper(right, mode: .range)))
      }
      if let triple = triple(right) { rule.prereleaseTriples.append(triple) }
      return rule
    }

    var rule = SetRule(comparisons: [], prereleaseTriples: [], universalReleaseOnly: false)
    var index = 0
    while index < words.count {
      var word = words[index]
      var op: String?
      if isOperator(word) {
        op = String(decoding: word, as: UTF8.self)
        index += 1
        guard index < words.count else { throw Failure(2, "bad") }
        word = words[index]
      } else if let found = attachedOperator(word) {
        op = found.0
        word = Array(word.dropFirst(found.1))
      }
      guard let partial = tryPartial(word) else { throw Failure(2, "bad") }
      if partial.wildcardFirst {
        guard op == nil || op == "=" else { throw Failure(2, "bad") }
        rule.universalReleaseOnly = true
      } else {
        add(partial, operator: op, to: &rule)
      }
      index += 1
    }
    guard !rule.comparisons.isEmpty || rule.universalReleaseOnly else { throw Failure(2, "bad") }
    return rule
  }

  private enum UpperMode { case range, caret, tilde }

  private static func add(_ p: Partial, operator op: String?, to rule: inout SetRule) {
    let op = op ?? "="
    if let triple = triple(p) { rule.prereleaseTriples.append(triple) }
    if op == "=" {
      if p.whole {
        rule.comparisons.append(Comparison(relation: .equal, version: p.version))
      } else {
        rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: p.version))
        rule.comparisons.append(Comparison(relation: .less, version: upper(p, mode: .range)))
      }
    } else if op == ">" {
      if p.whole {
        rule.comparisons.append(Comparison(relation: .greater, version: p.version))
      } else {
        rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: upper(p, mode: .range)))
      }
    } else if op == ">=" {
      rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: p.version))
    } else if op == "<" {
      rule.comparisons.append(Comparison(relation: .less, version: p.version))
    } else if op == "<=" {
      if p.whole {
        rule.comparisons.append(Comparison(relation: .lessOrEqual, version: p.version))
      } else {
        rule.comparisons.append(Comparison(relation: .less, version: upper(p, mode: .range)))
      }
    } else if op == "~" {
      rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: p.version))
      rule.comparisons.append(Comparison(relation: .less, version: upper(p, mode: .tilde)))
    } else if op == "^" {
      rule.comparisons.append(Comparison(relation: .greaterOrEqual, version: p.version))
      rule.comparisons.append(Comparison(relation: .less, version: upper(p, mode: .caret)))
    }
  }

  private static func upper(_ p: Partial, mode: UpperMode) -> Version {
    let m = p.version.major
    let n = p.version.minor
    let k = p.version.patch
    if mode == .range {
      return p.precision == 1 ? Version(m + 1, 0, 0) : Version(m, n + 1, 0)
    }
    if mode == .tilde {
      return p.precision < 2 ? Version(m + 1, 0, 0) : Version(m, n + 1, 0)
    }
    if m > 0 || p.precision == 1 { return Version(m + 1, 0, 0) }
    if n > 0 || p.precision == 2 { return Version(0, n + 1, 0) }
    return Version(0, 0, k + 1)
  }

  private static func tryPartial(_ bytes: [UInt8]) -> Partial? {
    guard !bytes.isEmpty else { return nil }
    if let suffix = bytes.firstIndex(where: { $0 == 45 || $0 == 43 }) {
      guard suffix > 0 else { return nil }
      let core = Array(bytes[..<suffix])
      let parts = split(core, on: [46])
      guard parts.count == 3, parts.allSatisfy({ number($0) != nil }) else { return nil }
      guard let version = Version.parse(String(decoding: bytes, as: UTF8.self)) else { return nil }
      return Partial(version: version, precision: 3, wildcardFirst: false, whole: true)
    }
    let parts = split(bytes, on: [46])
    guard (1...3).contains(parts.count) else { return nil }
    var nums: [Int] = []
    var sawWildcard = false
    for part in parts {
      if part == [120] || part == [88] || part == [42] {
        sawWildcard = true
        continue
      }
      guard !sawWildcard, let value = number(part) else { return nil }
      nums.append(value)
    }
    let firstWildcard = number(parts[0]) == nil
    if firstWildcard && nums.isEmpty {
      return Partial(version: Version(0, 0, 0), precision: 0, wildcardFirst: true, whole: false)
    }
    guard let m = number(parts[0]) else { return nil }
    let n = parts.count > 1 ? (number(parts[1]) ?? 0) : 0
    let k = parts.count > 2 ? (number(parts[2]) ?? 0) : 0
    let precision = parts.lastIndex(where: { number($0) != nil }).map { $0 + 1 } ?? 1
    return Partial(version: Version(m, n, k), precision: precision, wildcardFirst: false, whole: parts.count == 3 && !sawWildcard)
  }

  private static func number(_ bytes: [UInt8]) -> Int? {
    guard !bytes.isEmpty, bytes.count <= 6,
      bytes.allSatisfy({ $0 >= 48 && $0 <= 57 }),
      bytes.count == 1 || bytes[0] != 48
    else { return nil }
    return Int(String(decoding: bytes, as: UTF8.self))
  }

  private static func triple(_ p: Partial) -> (Int, Int, Int)? {
    guard p.whole, p.version.pre != nil else { return nil }
    return (p.version.major, p.version.minor, p.version.patch)
  }

  private static func isOperator(_ word: [UInt8]) -> Bool {
    [[61], [62], [62, 61], [60], [60, 61], [126], [94]].contains(word)
  }

  private static func attachedOperator(_ word: [UInt8]) -> (String, Int)? {
    let operators: [([UInt8], String)] = [([62, 61], ">="), ([60, 61], "<="), ([61], "="), ([62], ">"), ([60], "<"), ([126], "~"), ([94], "^")]
    for (bytes, name) in operators {
      if word.starts(with: bytes) { return (name, bytes.count) }
    }
    return nil
  }

  private static func tokens(_ bytes: [UInt8]) -> [[UInt8]] {
    var result: [[UInt8]] = []
    var start: Int?
    for index in 0...bytes.count {
      let separator = index == bytes.count || bytes[index] == 32 || bytes[index] == 9
      if separator {
        if let start { result.append(Array(bytes[start..<index])) }
        start = nil
      } else if start == nil {
        start = index
      }
    }
    return result
  }

  private static func split(_ bytes: [UInt8], on separator: [UInt8]) -> [[UInt8]] {
    var result: [[UInt8]] = []
    var start = 0
    var index = 0
    while index + separator.count <= bytes.count {
      if Array(bytes[index..<(index + separator.count)]) == separator {
        result.append(Array(bytes[start..<index]))
        index += separator.count
        start = index
      } else {
        index += 1
      }
    }
    result.append(Array(bytes[start..<bytes.count]))
    return result
  }
}
