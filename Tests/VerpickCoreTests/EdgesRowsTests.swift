import Testing

@Suite struct EdgesRowsTests {
  let rows: [Row] = [
    (["sort"], "#1.0.0\n1.0.0\n", 0, "1.0.0\n", ""),
    (["check"], "1.0.0\r", 0, "ok 1 version\n", ""),
    (["check"], "1.0.0\r\r\n", 1, "", "verpick: line 1: bad version 1.0.0\r\n"),
    (["best", "--range", "*"], "1.0.0-rc.1\n", 0, "none\n", ""),
    (["match", "--range", "*"], "0.0.0\n1.0.0-a\n1.0.0\n", 0, "0.0.0\n1.0.0\n", ""),
    (["match", "--range", ">=1.0.0 <1.0.0"], "1.0.0\n", 0, "", ""),
    (["match", "--range", "--pre"], "1.0.0\n", 2, "", "verpick: bad range --pre\n"),
    (["gap"], "", 0, "", ""),
    (["gap"], "1.0.0\n", 0, "", ""),
    (["bump", "--level", "minor"], "", 0, "", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
