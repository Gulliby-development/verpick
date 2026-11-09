public enum Registry {
  public static let version = "0.1.0"
  public static let maxLines = 30
  public static let maxNumber = 999_999
  public static let maxPreNumber = 999_999_999
  public static let commandNames = ["check", "sort", "match", "best", "bump", "gap"]
  public static let optionNames = ["--desc", "--range", "--pre", "--level"]
  public static let valueOptions = ["--range", "--level"]
  public static let levels = ["major", "minor", "patch", "pre"]

  /// The options each command accepts.
  public static let accepted: [String: [String]] = [
    "check": [],
    "sort": ["--desc"],
    "match": ["--range", "--pre"],
    "best": ["--range", "--pre"],
    "bump": ["--level"],
    "gap": [],
  ]

  public static let usage = """
    usage: verpick check
           verpick sort [--desc]
           verpick match --range RANGE [--pre]
           verpick best --range RANGE [--pre]
           verpick bump --level LEVEL
           verpick gap

    """
}

/// The options of one command line.
public struct Options: Equatable {
  public var desc = false
  public var range: String?
  public var pre = false
  public var level: String?

  public init() {}
}

/// A version: the numbers, the pre-release identifiers (nil when there is none) and the build text (nil when there is none).
public struct Version: Equatable {
  public var major: Int
  public var minor: Int
  public var patch: Int
  public var pre: [String]?
  public var build: String?

  public init(_ major: Int, _ minor: Int, _ patch: Int, pre: [String]? = nil, build: String? = nil) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self.pre = pre
    self.build = build
  }
}

/// One version of the list: its line number, the word as written and the parsed version.
public struct Entry: Equatable {
  public var line: Int
  public var word: String
  public var version: Version

  public init(line: Int, word: String, version: Version) {
    self.line = line
    self.word = word
    self.version = version
  }
}

/// The result of one command: the exit status and the two streams.
public struct Reply: Equatable {
  public var status: Int32
  public var out: String
  public var err: String

  public init(status: Int32, out: String, err: String) {
    self.status = status
    self.out = out
    self.err = err
  }
}

/// A failure that ends the command: status 1 for the list, 2 for the command line and for a bad range.
public struct Failure: Error, Equatable {
  public var status: Int32
  public var message: String

  public init(_ status: Int32, _ message: String) {
    self.status = status
    self.message = message
  }
}
