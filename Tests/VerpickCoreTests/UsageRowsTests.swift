import Testing

@Suite struct UsageRowsTests {
  let rows: [Row] = [
    (["help"], "", 0, "usage: verpick check\n       verpick sort [--desc]\n       verpick match --range RANGE [--pre]\n       verpick best --range RANGE [--pre]\n       verpick bump --level LEVEL\n       verpick gap\n", ""),
    (["-h", "extra"], "", 0, "usage: verpick check\n       verpick sort [--desc]\n       verpick match --range RANGE [--pre]\n       verpick best --range RANGE [--pre]\n       verpick bump --level LEVEL\n       verpick gap\n", ""),
    (["--help", "--bogus"], "", 0, "usage: verpick check\n       verpick sort [--desc]\n       verpick match --range RANGE [--pre]\n       verpick best --range RANGE [--pre]\n       verpick bump --level LEVEL\n       verpick gap\n", ""),
    (["--version"], "", 0, "verpick 0.1.0\n", ""),
    (["--version", "x"], "", 0, "verpick 0.1.0\n", ""),
    ([], "", 2, "", "usage: verpick check\n       verpick sort [--desc]\n       verpick match --range RANGE [--pre]\n       verpick best --range RANGE [--pre]\n       verpick bump --level LEVEL\n       verpick gap\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
