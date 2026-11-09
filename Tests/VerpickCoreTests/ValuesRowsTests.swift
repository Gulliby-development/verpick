import Testing

@Suite struct ValuesRowsTests {
  let rows: [Row] = [
    (["bump", "--level", "huge"], "", 2, "", "verpick: bad value for --level\n"),
    (["bump", "--level", "Major"], "", 2, "", "verpick: bad value for --level\n"),
    (["bump", "--level", ""], "", 2, "", "verpick: bad value for --level\n"),
    (["bump", "--level"], "", 2, "", "verpick: missing value for --level\n"),
    (["bump"], "", 2, "", "verpick: missing --level\n"),
    (["match"], "", 2, "", "verpick: missing --range\n"),
    (["bump", "--level", "pre", "--level", "pre"], "", 2, "", "verpick: given twice: --level\n"),
    (["bump", "--level", "major"], "1.2.3\n0.0.1\n", 0, "1.2.3 -> 2.0.0\n0.0.1 -> 1.0.0\n", ""),
    (["bump", "--level", "pre"], "1.2.3\n0.0.1-x\n", 0, "1.2.3 -> 1.2.4-0\n0.0.1-x -> 0.0.1-x.0\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
