import Testing

@Suite struct CheckRowsTests {
  let rows: [Row] = [
    (["check"], "1.0.0\n", 0, "ok 1 version\n", ""),
    (["check"], "# nothing\n\n", 0, "ok 0 versions\n", ""),
    (["check"], "1.0.0\n2.0.0\n3.0.0\n", 0, "ok 3 versions\n", ""),
    (["check"], "1.0.0\n2.0.0-rc.1\n", 0, "ok 2 versions, 1 pre-release\n", ""),
    (["check"], "1.0.0-a\n1.0.0-b\n1.0.0\n", 0, "ok 3 versions, 2 pre-releases\n", ""),
    (["check"], "1.0.0+b\n2.0.0+c\n", 0, "ok 2 versions\n", ""),
    (["check"], "1.0.0-x+y\n", 0, "ok 1 version, 1 pre-release\n", ""),
    (["check"], "1.0.0\n1.0.0\n", 0, "ok 2 versions\n", ""),
    (["check"], "1.0.0\n1.1.0\n1.2.0\n1.3.0\n1.4.0\n1.5.0\n1.6.0\n1.7.0\n1.8.0\n1.9.0\n1.10.0\n1.11.0\n1.12.0\n1.13.0\n1.14.0\n1.15.0\n1.16.0\n1.17.0\n1.18.0\n1.19.0\n1.20.0\n1.21.0\n1.22.0\n1.23.0\n1.24.0\n1.25.0\n1.26.0\n1.27.0\n1.28.0\n1.29.0\n", 0, "ok 30 versions\n", ""),
    (["check"], "# a\n\n1.0.0\nx\n", 1, "", "verpick: line 4: bad version x\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
