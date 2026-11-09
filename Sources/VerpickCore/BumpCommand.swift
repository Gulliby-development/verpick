/// Produces the next version for each parsed entry without exposing partial output.
public enum BumpCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    guard let level = options.level else {
      throw Failure(2, "missing --level")
    }

    var output = ""
    for entry in entries {
      guard let next = Bump.next(entry.version, level: level) else {
        throw Failure(1, "line \(entry.line): cannot bump \(entry.word)")
      }
      output += "\(entry.word) -> \(next.text)\n"
    }
    return output
  }
}
