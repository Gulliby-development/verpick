import Testing

@Suite struct BestRowsTests {
  let rows: [Row] = [
    (["best", "--range", "^1.2.3"], "1.2.3\n1.9.0\n1.5.0\n2.0.0\n", 0, "1.9.0\n", ""),
    (["best", "--range", "^3"], "1.0.0\n2.0.0\n", 0, "none\n", ""),
    (["best", "--range", "*"], "", 0, "none\n", ""),
    (["best", "--range", "=1.0.0"], "1.0.0+b\n1.0.0+a\n", 0, "1.0.0+b\n", ""),
    (["best", "--range", "^1.0.0"], "1.0.0\n1.1.0-rc.1\n", 0, "1.0.0\n", ""),
    (["best", "--range", "^1.0.0", "--pre"], "1.0.0\n1.1.0-rc.1\n", 0, "1.1.0-rc.1\n", ""),
    (["best", "--range", "<2"], "1.9.9\n1.10.0\n", 0, "1.10.0\n", ""),
    (["best", "--range", "1.0.0 - 1.5.0 || ^2"], "1.4.0\n1.6.0\n2.7.0\n3.0.0\n", 0, "2.7.0\n", ""),
  ]

  let refusals: [Row] = [
    (["best", "--range", "hello"], "1.0.0\n", 2, "", "verpick: bad range hello\n"),
    (["best", "--range", ""], "1.0.0\n", 2, "", "verpick: bad range \n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }

  @Test func matchesRefusals() {
    checkRows(refusals)
  }
}
