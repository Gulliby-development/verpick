public enum Cli {
  private enum Invocation {
    case help
    case version
    case command(String, Options)
  }

  public static func run(_ args: [String], input: String) -> Reply {
    guard !args.isEmpty else {
      return Reply(status: 2, out: "", err: Registry.usage)
    }

    do {
      switch try validate(args) {
      case .help:
        return Reply(status: 0, out: Registry.usage, err: "")
      case .version:
        return Reply(status: 0, out: "verpick \(Registry.version)\n", err: "")
      case let .command(name, options):
        let entries = try Input.read(input)
        let output: String
        switch name {
        case "check":
          output = try CheckCommand.run(options, entries)
        case "sort":
          output = try SortCommand.run(options, entries)
        case "match":
          output = try MatchCommand.run(options, entries)
        case "best":
          output = try BestCommand.run(options, entries)
        case "bump":
          output = try BumpCommand.run(options, entries)
        case "gap":
          output = try GapCommand.run(options, entries)
        default:
          return Reply(status: 2, out: "", err: "verpick: unknown command \(name)\n")
        }
        return Reply(status: 0, out: output, err: "")
      }
    } catch let failure as Failure {
      return Reply(status: failure.status, out: "", err: "verpick: \(failure.message)\n")
    } catch {
      return Reply(status: 2, out: "", err: "verpick: unknown command \(args[0])\n")
    }
  }

  public static func readsStdin(_ args: [String]) -> Bool {
    guard !args.isEmpty else {
      return false
    }
    switch Result(catching: { try validate(args) }) {
    case let .success(invocation):
      if case .command = invocation {
        return true
      }
      return false
    case .failure:
      return false
    }
  }

  private static func validate(_ args: [String]) throws -> Invocation {
    guard let command = args.first else {
      throw Failure(2, Registry.usage)
    }
    if command == "help" || command == "-h" || command == "--help" {
      return .help
    }
    if command == "--version" {
      return .version
    }
    guard Registry.commandNames.contains(command) else {
      throw Failure(2, "unknown command \(command)")
    }

    var options = Options()
    var seen: Set<String> = []
    var index = 1
    while index < args.count {
      let word = args[index]
      guard !word.isEmpty, word != "-", word.hasPrefix("-") else {
        throw Failure(2, "unexpected argument \(word)")
      }
      guard Registry.optionNames.contains(word) else {
        throw Failure(2, "unknown option \(word)")
      }
      guard Registry.accepted[command]?.contains(word) == true else {
        throw Failure(2, "option \(word) is not valid for \(command)")
      }
      guard seen.insert(word).inserted else {
        throw Failure(2, "given twice: \(word)")
      }

      if Registry.valueOptions.contains(word) {
        guard index + 1 < args.count else {
          throw Failure(2, "missing value for \(word)")
        }
        let value = args[index + 1]
        if word == "--range" {
          options.range = value
        } else {
          guard Registry.levels.contains(value) else {
            throw Failure(2, "bad value for --level")
          }
          options.level = value
        }
        index += 2
      } else {
        if word == "--desc" {
          options.desc = true
        } else if word == "--pre" {
          options.pre = true
        }
        index += 1
      }
    }

    if (command == "match" || command == "best"), options.range == nil {
      throw Failure(2, "missing --range")
    }
    if command == "bump", options.level == nil {
      throw Failure(2, "missing --level")
    }
    return .command(command, options)
  }
}
