/// Selects the first entry with the highest precedence in a range.
public enum BestCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    guard let rangeText = options.range else {
      throw Failure(2, "missing --range")
    }
    let range = try VersionRange(rangeText)
    var best: Entry?
    for entry in entries where range.contains(entry.version, pre: options.pre) {
      if let current = best {
        if Version.compare(entry.version, current.version) > 0 {
          best = entry
        }
      } else {
        best = entry
      }
    }
    return (best?.word ?? "none") + "\n"
  }
}
