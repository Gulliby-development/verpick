<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# verpick

[![CI](https://github.com/Gulliby-development/verpick/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/verpick/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

verpick is a deterministic, dependency-free command-line tool for teams that maintain lists of release versions and need to validate, sort, select, increment, or compare them. It follows the version and range rules described here, needs no network or clock, and reads a version list from standard input. It supports Swift 6.2 or newer on Windows, macOS, and Linux.

From the repository directory, run a command with `swift run verpick COMMAND`. For the examples below, `verpick` means this POSIX shell function, defined in the repository directory:

```sh
verpick() { swift run --quiet verpick "$@"; }
```

This shell-function example uses POSIX syntax; the application itself is intended to run on Windows, macOS, and Linux.

## Usage

```text
usage: verpick check
       verpick sort [--desc]
       verpick match --range RANGE [--pre]
       verpick best --range RANGE [--pre]
       verpick bump --level LEVEL
       verpick gap
```

Every command reads the list from standard input. `help`, `-h`, and `--help` as the first word print the synopsis and exit successfully, ignoring following words. `--version` likewise ignores following words and prints `verpick 0.1.0`.

Options are scanned from left to right: `sort` accepts `--desc`; `match` and `best` accept `--range RANGE` and `--pre`; `bump` accepts `--level LEVEL`; `check` and `gap` accept no options. Range and level values are the next argument, even if it begins with a hyphen. Levels are `major`, `minor`, `patch`, and `pre`.

## Versions

Input is split at line feeds. A final non-terminated line counts, but empty input has no lines; one carriage return at a line end is removed. Blank lines and lines whose first word begins with `#` are skipped. Elsewhere, spaces and tabs trim line edges and separate words; each non-skipped line must contain exactly one version. At most 30 lines are allowed, including skipped lines. The total line count is checked before validating any line, so an input over 30 lines is reported as too long even if it also contains malformed lines. For inputs within the limit, the first invalid line is reported with its original one-based line number. Original version words are retained for output.

A version has the form `MAJOR.MINOR.PATCH`, optionally followed by `-PRE` and then `+BUILD`. The three numeric components each have one to six decimal digits, no leading zero except for zero itself, and cannot exceed 999999. PRE and BUILD are dot-separated identifiers made from ASCII letters, digits, and hyphens. Numeric PRE identifiers cannot have leading zeroes and are limited to 999999999; BUILD numeric identifiers may have leading zeroes. A leading `v` is not allowed.

Precedence compares major, minor, then patch numerically. For equal components, a release outranks a pre-release. Pre-release identifiers compare from left to right: numeric identifiers compare numerically and rank below nonnumeric identifiers; other identifiers compare by ASCII order. If matching identifiers are exhausted, the shorter sequence ranks lower. Build text never affects precedence. Sorting and choosing among equal-precedence versions preserve input order.

## Ranges

`match` and `best` require `--range RANGE`. A range is one or more comparator sets separated by `||`; a version qualifies if any set accepts it. Within a set, one or more spaces or tabs separate comparator words, and all comparators must match. A standalone operator joins the following partial version, so `>= 1.5` is equivalent to `>=1.5`.

Operators are `=`, `>`, `>=`, `<`, `<=`, `~`, and `^`; omission means equality/range matching. Partial versions have one to three dot-separated numeric or wildcard parts. A wildcard is `x`, `X`, or `*`; omitted parts behave as wildcards, and no number may follow a wildcard. A wildcard in the first part accepts releases generally and is valid only alone or with equality. A partial version with a pre-release or build suffix must instead be a complete three-number version.

For an unqualified or `=` partial, a complete version matches that precedence; a two-part form spans that minor series, and a one-part form spans that major series. `>` on a complete version means strictly higher; on a partial it begins at the next minor or major boundary. `>=` starts at the partial's numeric lower bound, using zero for omitted components. `<` is strictly below that lower bound. `<=` on a complete version includes it; on a partial it ends before the next minor or major boundary.

`~` starts at its partial lower bound and ends before the next minor boundary, or before the next major for a one-part form. `^` starts at its lower bound, but its upper bound depends on how many numeric parts are present. For a complete `^M.N.K`, it ends before the next version that changes the first nonzero component: `(M+1).0.0` when M is nonzero, `0.(N+1).0` when M is zero and N is nonzero, or `0.0.(K+1)` when both are zero. For the two-part `^M.N`, it ends before `(M+1).0.0` when M is nonzero, or `0.(N+1).0` when M is zero. For the one-part `^M`, it ends before `(M+1).0.0`. Wildcard equivalents use those same partial bounds: `^M.N.x` follows `^M.N`, and `^M.x` or `^M.x.x` follows `^M`. A hyphen range has exactly the form `A - B`, where both ends start with numbers; its lower bound is inclusive, and its upper bound is inclusive for a complete version or exclusive at the next component boundary for a partial version. A set containing a hyphen word but not a valid hyphen range is invalid.

Empty sets, malformed partials, more than three parts, a number after a wildcard, an operator without a following partial, and a first-part wildcard after an operator other than equality are invalid. A bad range is reported using the original range text.

## Pre-releases

A pre-release version is admitted by a set only when it satisfies all that set's comparisons and at least one comparator in that same set names a pre-release with identical major, minor, and patch components. A pre-release comparator in another `||` set does not grant admission. The `--pre` option disables this extra admission rule; the comparison rules still apply. Build identifiers are never compared.

## Output

All successful command output goes to standard output; standard error is empty. Output lines end with a line feed.

- `check` prints `ok N versions`. It adds `, M pre-releases` when at least one pre-release is present. N and M use singular nouns only when their count is one. Empty or skipped-only input prints a zero-version count.
- `sort` prints original version words in precedence order, one per line. `--desc` reverses precedence order; equal versions remain in input order. An empty list prints nothing.
- `match` prints each original matching word in input order, or nothing if none match.
- `best` prints the highest-precedence matching original word and a line feed. The first input word wins a tie; no match or an empty list prints `none`.
- `bump` prints `OLD -> NEW` for each word in input order. The new value omits build text. Major produces the next major with zero minor and patch; a pre-release at a zero-minor, zero-patch boundary promotes to that release. Minor produces the next minor with zero patch, except a pre-release whose patch is zero promotes to that release. Patch increments patch for a release and removes PRE without changing components for a pre-release. Pre-release bumping starts a release at the next patch followed by identifier zero; for an existing pre-release it increments a numeric final identifier, or appends identifier zero when the final identifier is nonnumeric.
- `gap` sorts stably in ascending precedence and reports every adjacent pair as `A -> B KIND`. KIND is the first differing numeric component (`major +D`, `minor +D`, or `patch +D`), then `pre` if only precedence differs, otherwise `same`. D is the nonnegative component difference. Fewer than two versions prints nothing.

Examples use the shell function defined above:

```text
$ printf '1.4.0\n1.2.3-beta.1\n1.10.0\n' | verpick sort
1.2.3-beta.1
1.4.0
1.10.0
$ printf '1.2.3\n1.9.0\n2.0.0\n1.4.0-rc.1\n' | verpick match --range '^1.2.3'; printf '1.2.3\n1.9.0\n2.0.0\n' | verpick best --range '<2'
1.2.3
1.9.0
1.9.0
$ printf '1.2.3-rc.9\n2.0.0+b\n' | verpick bump --level pre; printf '1.0.0\n1.2.3\n' | verpick gap
1.2.3-rc.9 -> 1.2.3-rc.10
2.0.0+b -> 2.0.1-0
1.0.0 -> 1.2.3 minor +2
$ printf '1.0.0\n1.0' | verpick check 2>&1; printf '1.0.0\n' | verpick match --range '1.x.3' 2>&1
verpick: line 2: bad version 1.0
verpick: bad range 1.x.3
```

## Errors

A successful operation exits with status 0. A list or bump failure exits with status 1; a command-line or range failure exits with status 2. Failures write no standard output and one `verpick: MESSAGE` line to standard error. Except for the no-argument usage case, CLI failures are checked before input is read; list validation precedes command execution, so a list error wins over a range or command error. Within command-line options, the first invalid argument is reported.

With no arguments, the usage text goes to standard error and status 2. An unrecognized first word produces `verpick: unknown command WORD`. Later arguments that are empty, exactly `-`, or do not begin with a hyphen produce `verpick: unexpected argument WORD`; unrecognized hyphen-prefixed arguments produce `verpick: unknown option WORD`. A known but disallowed option produces `verpick: option OPTION is not valid for COMMAND`. Repeating an option produces `verpick: given twice: OPTION`; a final value-taking option produces `verpick: missing value for OPTION`; a level outside the four allowed words produces `verpick: bad value for --level`. Missing required values produce `verpick: missing --range` or `verpick: missing --level`.

List failures are `verpick: input is too long (max 30 lines)`, `verpick: line N: expected 1 version`, and `verpick: line N: bad version WORD`. Invalid ranges produce `verpick: bad range RANGE`, retaining the supplied range text. If a bump would exceed a numeric ceiling, the error is `verpick: line N: cannot bump WORD`; no partial bump output is written.

## Development

The Swift package uses the standard library for its core. The library receives input text and returns a reply containing status and output strings; only the executable entry point reads standard input and writes the reply to the process streams. The existing literal row suites exercise the command-line contract through the library; this guide does not require changing source or tests.

Run these commands from the repository directory:

```sh
swift format lint --strict --recursive .
swift build
swift test
```

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R100).
