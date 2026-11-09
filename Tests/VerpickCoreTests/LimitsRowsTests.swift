import Testing

@Suite struct LimitsRowsTests {
  let rows: [Row] = [
    (["check"], "1.0.0-999999999\n", 0, "ok 1 version, 1 pre-release\n", ""),
    (["sort"], "0.0.30\n0.0.29\n0.0.28\n0.0.27\n0.0.26\n0.0.25\n0.0.24\n0.0.23\n0.0.22\n0.0.21\n0.0.20\n0.0.19\n0.0.18\n0.0.17\n0.0.16\n0.0.15\n0.0.14\n0.0.13\n0.0.12\n0.0.11\n0.0.10\n0.0.9\n0.0.8\n0.0.7\n0.0.6\n0.0.5\n0.0.4\n0.0.3\n0.0.2\n0.0.1\n", 0, "0.0.1\n0.0.2\n0.0.3\n0.0.4\n0.0.5\n0.0.6\n0.0.7\n0.0.8\n0.0.9\n0.0.10\n0.0.11\n0.0.12\n0.0.13\n0.0.14\n0.0.15\n0.0.16\n0.0.17\n0.0.18\n0.0.19\n0.0.20\n0.0.21\n0.0.22\n0.0.23\n0.0.24\n0.0.25\n0.0.26\n0.0.27\n0.0.28\n0.0.29\n0.0.30\n", ""),
    (["check"], "1.0.0-1000000000\n", 1, "", "verpick: line 1: bad version 1.0.0-1000000000\n"),
    (["check"], "# c1\n# c2\n# c3\n# c4\n# c5\n# c6\n# c7\n# c8\n# c9\n# c10\n# c11\n# c12\n# c13\n# c14\n# c15\n# c16\n# c17\n# c18\n# c19\n# c20\n# c21\n# c22\n# c23\n# c24\n# c25\n# c26\n# c27\n# c28\n# c29\nx\n", 1, "", "verpick: line 30: bad version x\n"),
    (["bump", "--level", "major"], "999999.0.0\n", 1, "", "verpick: line 1: cannot bump 999999.0.0\n"),
    (["bump", "--level", "pre"], "1.0.0-999999999\n", 1, "", "verpick: line 1: cannot bump 1.0.0-999999999\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
