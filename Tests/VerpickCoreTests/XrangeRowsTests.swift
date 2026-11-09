import Testing

@Suite struct XrangeRowsTests {
  let rows: [Row] = [
    (["match", "--range", "*"], "0.0.0\n3.4.5\n1.0.0-a\n", 0, "0.0.0\n3.4.5\n", ""),
    (["match", "--range", "1.x"], "0.9.0\n1.0.0\n1.9.9\n2.0.0\n", 0, "1.0.0\n1.9.9\n", ""),
    (["match", "--range", "1.2.x"], "1.1.9\n1.2.0\n1.2.9\n1.3.0\n", 0, "1.2.0\n1.2.9\n", ""),
    (["match", "--range", "1.2"], "1.2.0\n1.2.7\n1.3.0\n", 0, "1.2.0\n1.2.7\n", ""),
    (["match", "--range", ">1.2.3"], "1.2.3\n1.2.4\n2.0.0\n", 0, "1.2.4\n2.0.0\n", ""),
    (["match", "--range", ">1.2"], "1.2.9\n1.3.0\n", 0, "1.3.0\n", ""),
    (["match", "--range", "<1.2"], "1.1.9\n1.2.0\n", 0, "1.1.9\n", ""),
    (["match", "--range", "<=1.2"], "1.2.9\n1.3.0\n", 0, "1.2.9\n", ""),
    (["match", "--range", "=1.2.3"], "1.2.3\n1.2.3+b\n1.2.4\n", 0, "1.2.3\n1.2.3+b\n", ""),
    (["match", "--range", ">= 1.5 < 2"], "1.4.0\n1.5.0\n1.9.0\n2.0.0\n", 0, "1.5.0\n1.9.0\n", ""),
    (["match", "--range", "1.*.*"], "1.4.0\n2.0.0\n", 0, "1.4.0\n", ""),
  ]

  let refusals: [Row] = [

    (["match", "--range", "1.x.3"], "1.0.0\n", 2, "", "verpick: bad range 1.x.3\n"),
    (["match", "--range", ">*"], "1.0.0\n", 2, "", "verpick: bad range >*\n"),
    (["match", "--range", "1.2-beta"], "1.0.0\n", 2, "", "verpick: bad range 1.2-beta\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }

  @Test func matchesRefusals() {
    checkRows(refusals)
  }
}
