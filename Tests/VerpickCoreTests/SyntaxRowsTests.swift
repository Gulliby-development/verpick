import Testing

@Suite struct SyntaxRowsTests {
  let rows: [Row] = [
    (["check"], "0.0.0\n999999.999999.999999\n", 0, "ok 2 versions\n", ""),
    (["check"], "1.2.3-alpha.1\n1.2.3+build.5\n1.2.3-rc.1+b.7\n", 0, "ok 3 versions, 2 pre-releases\n", ""),
    (["check"], "1.2.3-0\n1.2.3--\n1.2.3-a-b.c\n1.0.0-x+y-z\n", 0, "ok 4 versions, 4 pre-releases\n", ""),
    (["check"], "1.2\n", 1, "", "verpick: line 1: bad version 1.2\n"),
    (["check"], "1.2.3.4\n", 1, "", "verpick: line 1: bad version 1.2.3.4\n"),
    (["check"], "v1.2.3\n", 1, "", "verpick: line 1: bad version v1.2.3\n"),
    (["check"], "01.2.3\n", 1, "", "verpick: line 1: bad version 01.2.3\n"),
    (["check"], "1.2.3-\n", 1, "", "verpick: line 1: bad version 1.2.3-\n"),
    (["check"], "1.2.3-01\n", 1, "", "verpick: line 1: bad version 1.2.3-01\n"),
    (["check"], "1.2.3-a..b\n", 1, "", "verpick: line 1: bad version 1.2.3-a..b\n"),
    (["check"], "1.2.3+\n", 1, "", "verpick: line 1: bad version 1.2.3+\n"),
    (["check"], "1.2.3+a..b\n", 1, "", "verpick: line 1: bad version 1.2.3+a..b\n"),
    (["check"], "1000000.0.0\n", 1, "", "verpick: line 1: bad version 1000000.0.0\n"),
    (["check"], "1.2.3-1234567890\n", 1, "", "verpick: line 1: bad version 1.2.3-1234567890\n"),
    (["check"], "1.2.3-a_b\n", 1, "", "verpick: line 1: bad version 1.2.3-a_b\n"),
    (["check"], "1.0.0\n1.-2.3\n", 1, "", "verpick: line 2: bad version 1.-2.3\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
