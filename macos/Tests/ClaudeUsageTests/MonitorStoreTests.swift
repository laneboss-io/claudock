import XCTest
import UsageCore
@testable import ClaudeUsage

final class MonitorStoreTests: XCTestCase {
    func testAnalyticsLoadsOnlyOnDemandAndRefreshesWhenRequested() async {
        await MainActor.run {
            let store = MonitorStore(isDemo: true)
            store.refresh()
            XCTAssertFalse(store.accounts.isEmpty)
            XCTAssertNil(store.analytics, "The accounts widget should not scan or build analytics at startup")
            store.loadAnalytics(force: false)
            XCTAssertNotNil(store.analytics)
            store.analyticsDays = 30
            XCTAssertNotNil(store.analytics)
        }
    }

    func testVertexBudgetIsVisibleAndFilterable() throws {
        let vertex = try VertexConfiguration(project: "example-project", region: "global")
        let profile = Profile(command: "claude-cloud", configDirectory: "/tmp/cloud", managed: true, authKind: .vertex, vertex: vertex)
        let account = AccountState(profile: profile, credit: APICreditStatus(balance: 100, spent: 25, asOf: Date()))
        XCTAssertEqual(account.percentLeft(at: Date()), 75)
        XCTAssertEqual(account.consoleLabel, "Vertex AI · example-project · global")
        XCTAssertTrue(AccountKindFilter.vertex.includes(profile))
        XCTAssertFalse(AccountKindFilter.subscription.includes(profile))
    }
}
