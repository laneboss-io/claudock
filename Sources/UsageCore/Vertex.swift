import Foundation

/// Google Cloud project and region used by Claude Code with Application Default Credentials.
public struct VertexConfiguration: Codable, Hashable, Sendable {
    public let project: String
    public let region: String

    public init(project: String, region: String) throws {
        self.project = project
        self.region = region
        guard isValid else { throw MonitorError.unsupported("Enter a valid Google Cloud project ID and Vertex region, such as my-project and us-east5.") }
    }

    public var isValid: Bool {
        project.range(of: #"\A[a-z][a-z0-9-]{4,28}[a-z0-9]\z"#, options: .regularExpression) != nil &&
        region.range(of: #"\A[a-z0-9]+(?:-[a-z0-9]+)*\z"#, options: .regularExpression) != nil && region.count <= 63
    }
}
