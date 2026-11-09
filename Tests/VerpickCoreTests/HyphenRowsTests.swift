import Testing

@Suite struct HyphenRowsTests {
  let rows: [Row] = [
    (["match", "--range", "1.2.3 - 2.3.4"], "1.2.2\n1.2.3\n2.3.4\n2.3.5\n", 0, "1.2.3\n2.3.4\n", ""),
    (["match", "--range", "1.2 - 2.3"], "1.1.9\n1.2.0\n2.3.9\n2.4.0\n", 0, "1.2.0\n2.3.9\n", ""),
    (["match", "--range", "1.2.3 - 2"], "1.2.3\n2.9.9\n3.0.0\n", 0, "1.2.3\n2.9.9\n", ""),
    (["match", "--range", "1 - 2"], "0.9.9\n1.0.0\n2.9.9\n3.0.0\n", 0, "1.0.0\n2.9.9\n", ""),
    (["match", "--range", "1.0.0 || 2.0.0"], "1.0.0\n1.5.0\n2.0.0\n", 0, "1.0.0\n2.0.0\n", ""),
    (["match", "--range", "^1.0.0 || ^3.0.0"], "1.5.0\n2.5.0\n3.5.0\n", 0, "1.5.0\n3.5.0\n", ""),
    (["match", "--range", "  ^1.2.3   ||   >=3 <3.5  "], "1.3.0\n3.1.0\n3.5.0\n", 0, "1.3.0\n3.1.0\n", ""),
    (["match", "--range", "^ 1.2.3"], "1.2.3\n2.0.0\n", 0, "1.2.3\n", ""),
  ]

  let refusals: [Row] = [
    (["match", "--range", "1.0.0 ||"], "1.0.0\n", 2, "", "verpick: bad range 1.0.0 ||\n"),
    (["match", "--range", "1.2.3 - 2.0.0 <3"], "1.0.0\n", 2, "", "verpick: bad range 1.2.3 - 2.0.0 <3\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }

  @Test func matchesRefusals() {
    checkRows(refusals)
  }
}
