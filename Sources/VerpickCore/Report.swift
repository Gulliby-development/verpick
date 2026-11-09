/// Formats a count with its singular or plural noun.
public enum Report {
  public static func plural(_ count: Int, _ noun: String) -> String {
    "\(count) \(noun)\(count == 1 ? "" : "s")"
  }
}
