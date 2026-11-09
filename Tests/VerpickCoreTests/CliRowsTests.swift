import Testing

@Suite struct CliRowsTests {
  let rows: [Row] = [
    (["check"], "1.0.0\n2.0.0-rc.1\n", 0, "ok 2 versions, 1 pre-release\n", ""),
    (["sort"], "2.0.0\n1.0.0\n", 0, "1.0.0\n2.0.0\n", ""),
    (["frob"], "", 2, "", "verpick: unknown command frob\n"),
    ([""], "", 2, "", "verpick: unknown command \n"),
    (["Check"], "", 2, "", "verpick: unknown command Check\n"),
    (["match", "--range", "^1.2.3"], "1.2.3\n1.9.0\n2.0.0\n", 0, "1.2.3\n1.9.0\n", ""),
    (["best", "--range", "<2"], "1.0.0\n1.5.0\n2.0.0\n", 0, "1.5.0\n", ""),
    (["bump", "--level", "patch"], "1.2.3\n", 0, "1.2.3 -> 1.2.4\n", ""),
    (["gap"], "1.0.0\n1.0.1\n2.0.0\n", 0, "1.0.0 -> 1.0.1 patch +1\n1.0.1 -> 2.0.0 major +1\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
