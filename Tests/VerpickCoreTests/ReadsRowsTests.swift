import Testing

@Suite struct ReadsRowsTests {
  let rows: [Row] = [
    (["check"], "", 1, "", ""),
    (["sort", "--desc"], "", 1, "", ""),
    (["match", "--range", "^1"], "", 1, "", ""),
    (["match", "--range", "not a range"], "", 1, "", ""),
    (["bump", "--level", "major"], "", 1, "", ""),
    (["bump", "--level", "big"], "", 0, "", ""),
    (["help"], "", 0, "", ""),
    (["--version"], "", 0, "", ""),
    (["gap", "x"], "", 0, "", ""),
  ]

  @Test func matchesRows() {
    checkReads(rows)
  }
}
