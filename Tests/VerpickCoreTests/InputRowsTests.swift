import Testing

@Suite struct InputRowsTests {
  let rows: [Row] = [
    (["check"], "", 0, "ok 0 versions\n", ""),
    (["check"], "\n", 0, "ok 0 versions\n", ""),
    (["check"], "# only a comment\n   \n\n", 0, "ok 0 versions\n", ""),
    (["check"], "1.0.0", 0, "ok 1 version\n", ""),
    (["check"], "1.0.0\r\n2.0.0\r\n", 0, "ok 2 versions\n", ""),
    (["check"], "  1.0.0\t\n\t2.0.0  \n", 0, "ok 2 versions\n", ""),
    (["check"], "1.0.0\n1.0.1\n1.0.2\n1.0.3\n1.0.4\n1.0.5\n1.0.6\n1.0.7\n1.0.8\n1.0.9\n1.0.10\n1.0.11\n1.0.12\n1.0.13\n1.0.14\n1.0.15\n1.0.16\n1.0.17\n1.0.18\n1.0.19\n1.0.20\n1.0.21\n1.0.22\n1.0.23\n1.0.24\n1.0.25\n1.0.26\n1.0.27\n1.0.28\n1.0.29\n", 0, "ok 30 versions\n", ""),
    (["check"], "# c1\n# c2\n# c3\n# c4\n# c5\n# c6\n# c7\n# c8\n# c9\n# c10\n# c11\n# c12\n# c13\n# c14\n# c15\n# c16\n# c17\n# c18\n# c19\n# c20\n# c21\n# c22\n# c23\n# c24\n# c25\n# c26\n# c27\n# c28\n# c29\n# c30\n1.0.0\n", 1, "", "verpick: input is too long (max 30 lines)\n"),
    (["check"], "# c\n\nbad\n", 1, "", "verpick: line 3: bad version bad\n"),
    (["check"], "1.0.0 2.0.0\n", 1, "", "verpick: line 1: expected 1 version\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
