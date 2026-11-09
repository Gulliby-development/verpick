import Testing

@testable import VerpickCore

@Suite struct ScaffoldTests {
  @Test func loadsTheRegistry() {
    #expect(Registry.version == "0.1.0")
  }
}
