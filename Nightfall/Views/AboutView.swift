import SwiftUI

struct AboutView: View {
	/// The app's version number as a string (e.g. "1.2.3")
	private let versionString: String? = {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	}()
	
	/// The app's build number as a string
	private let buildString: String? = {
		return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
	}()
	
	/// The contents of the "About.txt" file
	private let aboutText: String? = {
		guard let fileURL = Bundle.main.url(forResource: "About", withExtension: "txt")
			else { return nil }
		return try? String(contentsOf: fileURL, encoding: .utf8)
	}()
	
	/// Open's the project's GitHub page
	private func openGithubURL() {
		if let url = URL(string: "https://github.com/\(GithubAPI.repoFullName)") {
			NSWorkspace.shared.open(url)
		}
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 20) {
			Image(nsImage: NSApp.applicationIconImage)
				.resizable()
				.aspectRatio(1.0, contentMode: .fit)
				.frame(width: 64)
			
			VStack(alignment: .leading, spacing: 8) {
				HStack(alignment: .lastTextBaseline, spacing: 5) {
					Text("Nightfall")
						.font(.system(size: 13, weight: .semibold))
					Text("Version \(versionString ?? "?") (\(buildString ?? "?"))")
						.font(.system(size: 9))
						.foregroundColor(.secondary)
				}
				
				ScrollView {
					Text(aboutText ?? "Unable to load About.txt")
						.font(.system(size: 11))
						.padding(.trailing, 2) // Fixes clipping on the right side
				}
				
				Button("github.com/r-thomson/Nightfall", action: openGithubURL)
					.buttonStyle(BorderlessButtonStyle())
					.font(.system(size: 11, weight: .medium))
					.cursor(.pointingHand)
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
		}
		.padding(.top, 10)
		.padding([.leading, .bottom, .trailing])
		.frame(width: 450, height: 180)
	}
}

#if DEBUG
struct AboutViewPreview: PreviewProvider {
	static var previews: some View {
		AboutView()
	}
}
#endif
