import Foundation
import XCTest
@testable import UsageCore

final class VertexProfileTests: XCTestCase {
    func testVertexLifecycleLaunchAndBudget() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("claudock-vertex-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: home) }
        let config = try VertexConfiguration(project: "example-project", region: "us-east5")
        let profile = try ProfileStore.addVertexProfile(name: "cloud", vertex: config, home: home.path)
        XCTAssertEqual(try ProfileStore.load(home: home.path).first { $0.id == profile.id }, profile)
        let registry = ProfileStore.directory(home: home.path).appendingPathComponent("profiles.json")
        let state = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: registry)) as? [String: Any])
        XCTAssertEqual(state["version"] as? Int, 4)
        XCTAssertTrue(try ProfileStore.shellProfileNames(home: home.path).contains("claude-cloud"))
        let env = try LaunchCommand.environment(profile: profile, inherited: ["ANTHROPIC_API_KEY": "wrong", "CLAUDE_CODE_USE_BEDROCK": "1", "GOOGLE_APPLICATION_CREDENTIALS": "/tmp/adc.json"])
        XCTAssertEqual(env["CLAUDE_CODE_USE_VERTEX"], "1")
        XCTAssertEqual(env["ANTHROPIC_VERTEX_PROJECT_ID"], "example-project")
        XCTAssertEqual(env["CLOUD_ML_REGION"], "us-east5")
        XCTAssertEqual(env["GOOGLE_APPLICATION_CREDENTIALS"], "/tmp/adc.json")
        XCTAssertNil(env["ANTHROPIC_API_KEY"])
        XCTAssertNil(env["CLAUDE_CODE_USE_BEDROCK"])
        XCTAssertEqual(try InferenceTokenPolicy.launchCredential(profile: profile, claudeArguments: [], signIn: false, requireToken: true, mint: { _ in XCTFail("Vertex must not read a subscription token"); return nil }), .vertex)
        let budget = try APICreditStore.setBalance(100, profile: profile, home: home.path, now: Date())
        XCTAssertEqual(budget.left, 100)
        XCTAssertTrue(AccountAvailability.classify(profile: profile, snapshot: nil, error: nil, credit: budget, now: Date()).hasRoom)
        let renamed = try ProfileStore.rename(profile: profile, to: "cloud2", home: home.path)
        XCTAssertEqual(renamed.vertex, config)
        XCTAssertEqual(renamed.id, profile.id)
        try ProfileStore.remove(profile: renamed, home: home.path)
        XCTAssertFalse(try ProfileStore.load(home: home.path).contains { $0.id == profile.id })
    }

    func testInvalidConfigurationAndRegistryAreRejected() throws {
        for project in ["", "BAD PROJECT", "../bad", "short", "project-with-trailing-"] {
            XCTAssertThrowsError(try VertexConfiguration(project: project, region: "us-east5"))
        }
        for region in ["", "US EAST", "us-east5/other", "-region"] {
            XCTAssertThrowsError(try VertexConfiguration(project: "example-project", region: region))
        }
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("claudock-vertex-invalid-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: home) }
        _ = try ProfileStore.addVertexProfile(name: "cloud", vertex: VertexConfiguration(project: "example-project", region: "global"), home: home.path)
        let registry = ProfileStore.directory(home: home.path).appendingPathComponent("profiles.json")
        var state = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: registry)) as? [String: Any])
        var profiles = try XCTUnwrap(state["profiles"] as? [[String: Any]])
        let index = try XCTUnwrap(profiles.firstIndex { $0["authKind"] as? String == "vertex" })
        profiles[index]["vertex"] = ["project": "broken project", "region": "global"]
        state["profiles"] = profiles
        try JSONSerialization.data(withJSONObject: state).write(to: registry)
        XCTAssertThrowsError(try ProfileStore.load(home: home.path))
    }
}
