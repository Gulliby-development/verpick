/// Reports the difference between each adjacent pair in sorted version order.
public enum GapCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    let sorted = entries.enumerated().sorted { left, right in
      let comparison = Version.compare(left.element.version, right.element.version)
      if comparison == 0 {
        return left.offset < right.offset
      }
      return comparison < 0
    }

    guard sorted.count > 1 else {
      return ""
    }

    var output = ""
    for index in 0..<(sorted.count - 1) {
      let earlier = sorted[index].element
      let later = sorted[index + 1].element
      let first = earlier.version
      let second = later.version
      let kind: String

      if first.major != second.major {
        kind = "major +\(second.major - first.major)"
      } else if first.minor != second.minor {
        kind = "minor +\(second.minor - first.minor)"
      } else if first.patch != second.patch {
        kind = "patch +\(second.patch - first.patch)"
      } else if Version.compare(first, second) != 0 {
        kind = "pre"
      } else {
        kind = "same"
      }

      output += "\(earlier.word) -> \(later.word) \(kind)\n"
    }
    return output
  }
}
