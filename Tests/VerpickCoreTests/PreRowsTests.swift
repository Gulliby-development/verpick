import Testing

@Suite struct PreRowsTests {
  let rows: [Row] = [
    (["match", "--range", "^1.2.3"], "1.2.3-beta.1\n1.2.4-beta.1\n1.3.0\n", 0, "1.3.0\n", ""),
    (["match", "--range", "^1.2.3-beta.2"], "1.2.3-beta.1\n1.2.3-beta.2\n1.2.3-beta.4\n1.2.4-beta.1\n1.2.4\n", 0, "1.2.3-beta.2\n1.2.3-beta.4\n1.2.4\n", ""),
    (["match", "--range", ">=1.0.0-rc.1 <1.0.0"], "1.0.0-rc.1\n1.0.0-rc.2\n1.0.0\n", 0, "1.0.0-rc.1\n1.0.0-rc.2\n", ""),
    (["match", "--range", "=1.0.0-rc.1"], "1.0.0-rc.1\n1.0.0-rc.1+b\n1.0.0-rc.2\n", 0, "1.0.0-rc.1\n1.0.0-rc.1+b\n", ""),
    (["match", "--range", "*", "--pre"], "1.0.0-a\n1.0.0\n", 0, "1.0.0-a\n1.0.0\n", ""),
    (["match", "--range", "^1.2.3", "--pre"], "1.2.4-beta.1\n2.0.0-rc.1\n1.2.2-a\n", 0, "1.2.4-beta.1\n2.0.0-rc.1\n", ""),
    (["match", "--range", "<2.0.0"], "2.0.0-rc.1\n1.9.0\n", 0, "1.9.0\n", ""),
    (["match", "--range", "<2.0.0-0", "--pre"], "2.0.0-rc.1\n1.9.0-a\n1.9.0\n", 0, "1.9.0-a\n1.9.0\n", ""),
    (["match", "--range", "~1.2.3-beta.2"], "1.2.3-beta.1\n1.2.3-beta.5\n1.2.9-beta.1\n1.2.9\n", 0, "1.2.3-beta.5\n1.2.9\n", ""),
  ]

  let refusals: [Row] = [
    (["match", "--range", "1.x-beta"], "1.0.0\n", 2, "", "verpick: bad range 1.x-beta\n"),
    (["match", "--range", "1.0.0-"], "1.0.0\n", 2, "", "verpick: bad range 1.0.0-\n"),
    (["match", "--range", "1.0.0-01"], "1.0.0\n", 2, "", "verpick: bad range 1.0.0-01\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }

  @Test func matchesRefusals() {
    checkRows(refusals)
  }
}
