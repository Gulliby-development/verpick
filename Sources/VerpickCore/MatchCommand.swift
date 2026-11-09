/// Selects list entries accepted by a version range.
public enum MatchCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    guard let rangeText = options.range else {
      throw Failure(2, "missing --range")
    }
    let range = try VersionRange(rangeText)
    return
      entries
      .filter { range.contains($0.version, pre: options.pre) }
      .map { $0.word + "\n" }
      .joined()
  }
}
