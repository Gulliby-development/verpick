/// Placeholder: the first task replaces this file with the check command.
public enum CheckCommand {
  public static func run(_ options: Options, _ entries: [Entry]) throws -> String {
    let versions = Report.plural(entries.count, "version")
    let prereleaseCount = entries.count(where: { $0.version.pre != nil })
    let prereleases = prereleaseCount == 0 ? "" : ", " + Report.plural(prereleaseCount, "pre-release")
    return "ok \(versions)\(prereleases)\n"
  }
}
