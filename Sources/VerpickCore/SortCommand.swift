/// Sorts list entries by version precedence while keeping equal versions in input order.
public enum SortCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    let sorted = entries.enumerated().sorted { left, right in
      let comparison = Version.compare(left.element.version, right.element.version)
      if comparison == 0 {
        return left.offset < right.offset
      }
      return options.desc ? comparison > 0 : comparison < 0
    }
    return sorted.map { $0.element.word + "\n" }.joined()
  }
}
