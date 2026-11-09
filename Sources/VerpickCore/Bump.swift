public enum Bump {
  public static func next(_ version: Version, level: String) -> Version? {
    switch level {
    case "major":
      if version.pre != nil, version.minor == 0, version.patch == 0 {
        return Version(version.major, 0, 0)
      }
      guard version.major < Registry.maxNumber else {
        return nil
      }
      return Version(version.major + 1, 0, 0)
    case "minor":
      if version.pre != nil, version.patch == 0 {
        return Version(version.major, version.minor, 0)
      }
      guard version.minor < Registry.maxNumber else {
        return nil
      }
      return Version(version.major, version.minor + 1, 0)
    case "patch":
      if version.pre != nil {
        return Version(version.major, version.minor, version.patch)
      }
      guard version.patch < Registry.maxNumber else {
        return nil
      }
      return Version(version.major, version.minor, version.patch + 1)
    case "pre":
      guard let identifiers = version.pre else {
        guard version.patch < Registry.maxNumber else {
          return nil
        }
        return Version(version.major, version.minor, version.patch + 1, pre: ["0"])
      }
      guard let last = identifiers.last else {
        return nil
      }
      let bytes = Array(last.utf8)
      let isNumeric = !bytes.isEmpty && bytes.allSatisfy { $0 >= 48 && $0 <= 57 }
      var nextIdentifiers = identifiers
      if isNumeric {
        guard let number = Int(last), number < Registry.maxPreNumber else {
          return nil
        }
        nextIdentifiers[nextIdentifiers.count - 1] = String(number + 1)
      } else {
        nextIdentifiers.append("0")
      }
      return Version(version.major, version.minor, version.patch, pre: nextIdentifiers)
    default:
      return nil
    }
  }
}
