import Foundation

enum GithubAPI {
	/// The full name of Nightfall's GitHub repository (account name and repo name)
	static let repoFullName = "r-thomson/Nightfall"
	
	/// Base API endpoint for Nightfall's GitHub repository
	static let repoApiUrl = URL(string: "https://api.github.com/repos/\(repoFullName)/")!
	
	/// Fetches the latest non-prerelease, non-draft release from the Nightfall GitHub repository.
	/// - Parameter completion: Completion handler to be called once the network request is finished.
	static func getLatestRelease(completion: @escaping (Result<Release, Error>) -> Void) {
		let endpoint = repoApiUrl.appendingPathComponent("releases/latest")
		let request = URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData)
		
		URLSession.shared.dataTask(with: request) { (data, res, err) in
			if let error = err {
				completion(.failure(error))
				return
			}
			
			// TODO: Handle and call completion() when data is nil
			if let data = data {
				do {
					let decoder = JSONDecoder()
					let decoded = try decoder.decode(Release.self, from: data)
					completion(.success(decoded))
				} catch {
					completion(.failure(error))
				}
			}
		}.resume()
	}
}
