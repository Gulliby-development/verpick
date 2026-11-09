import Testing

@Suite struct CaretRowsTests {
  let rows: [Row] = [
    (["match", "--range", "^1.2.3"], "1.2.2\n1.2.3\n1.9.9\n2.0.0\n", 0, "1.2.3\n1.9.9\n", ""),
    (["match", "--range", "^0.2.3"], "0.2.2\n0.2.3\n0.2.9\n0.3.0\n", 0, "0.2.3\n0.2.9\n", ""),
    (["match", "--range", "^0.0.3"], "0.0.2\n0.0.3\n0.0.4\n", 0, "0.0.3\n", ""),
    (["match", "--range", "^1.2"], "1.1.9\n1.2.0\n1.99.0\n2.0.0\n", 0, "1.2.0\n1.99.0\n", ""),
    (["match", "--range", "^0.0"], "0.0.0\n0.0.9\n0.1.0\n", 0, "0.0.0\n0.0.9\n", ""),
    (["match", "--range", "^0"], "0.0.1\n0.9.9\n1.0.0\n", 0, "0.0.1\n0.9.9\n", ""),
    (["match", "--range", "~1.2.3"], "1.2.2\n1.2.3\n1.2.99\n1.3.0\n", 0, "1.2.3\n1.2.99\n", ""),
    (["match", "--range", "~1.2"], "1.1.9\n1.2.0\n1.3.0\n", 0, "1.2.0\n", ""),
    (["match", "--range", "~1"], "0.9.9\n1.0.0\n1.9.9\n2.0.0\n", 0, "1.0.0\n1.9.9\n", ""),
  ]

  let refusals: [Row] = [
    (["match", "--range", "^"], "1.0.0\n", 2, "", "verpick: bad range ^\n"),
    (["match", "--range", "^*"], "1.0.0\n", 2, "", "verpick: bad range ^*\n"),
    (["match", "--range", "~1.2.3.4"], "1.0.0\n", 2, "", "verpick: bad range ~1.2.3.4\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }

  @Test func matchesRefusals() {
    checkRows(refusals)
  }
}
