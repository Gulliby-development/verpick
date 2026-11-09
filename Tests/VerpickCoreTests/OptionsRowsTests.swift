import Testing

@Suite struct OptionsRowsTests {
  let rows: [Row] = [
    (["check", "--desc"], "", 2, "", "verpick: option --desc is not valid for check\n"),
    (["sort", "--range", "1"], "", 2, "", "verpick: option --range is not valid for sort\n"),
    (["match", "--level", "major"], "", 2, "", "verpick: option --level is not valid for match\n"),
    (["bump", "--pre"], "", 2, "", "verpick: option --pre is not valid for bump\n"),
    (["gap", "--desc"], "", 2, "", "verpick: option --desc is not valid for gap\n"),
    (["sort", "--desc", "--desc"], "", 2, "", "verpick: given twice: --desc\n"),
    (["match", "--range"], "", 2, "", "verpick: missing value for --range\n"),
    (["sort", "stray"], "", 2, "", "verpick: unexpected argument stray\n"),
    (["match", "--nope", "1"], "", 2, "", "verpick: unknown option --nope\n"),
    (["match", "--range", "^1", "--pre"], "1.2.0\n1.3.0-rc.1\n", 0, "1.2.0\n1.3.0-rc.1\n", ""),
    (["bump", "--level", "minor"], "1.2.3\n", 0, "1.2.3 -> 1.3.0\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
