import Foundation

extension GithubAPI {
	/// # Reference
	/// <https://developer.github.com/v3/repos/releases/>
	struct Release: Codable {
		let name: String
		let version: String
		let url: URL
		let isPrerelease: Bool
		
		enum CodingKeys: String, CodingKey {
			case name
			case version = "tag_name"
			case url = "html_url"
			case isPrerelease = "prerelease"
		}
	}
}
