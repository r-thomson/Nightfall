//
//  AboutViewController.swift
//  Nightfall
//
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
	
	static let shared =  NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "About Window Controller") as! NSWindowController
	
	@IBOutlet var titleText: NSTextField!
	@IBOutlet var versionText: NSTextField!
	@IBOutlet var descriptionText: NSTextField!
	@IBOutlet var websiteText: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initBundleInfo()
		initDescriptionText()
	}
	
	func initBundleInfo() {
		if let info = Bundle.main.infoDictionary {
			let version = info["CFBundleShortVersionString"] as? String ?? "?"
			versionText.stringValue = "Version \(version)"
		}
	}
	
	func initDescriptionText() {
		if let fileURL = Bundle.main.url(forResource: "About", withExtension: "rtf") {
			if let fileText = try? NSAttributedString(url: fileURL, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
				descriptionText.attributedStringValue = fileText
			}
		}
	}
	
	@IBAction func websiteLinkClicked(_ sender: NSClickGestureRecognizer) {
		if let url = URL(string: "https://github.com/r-thomson/Nightfall") {
			NSWorkspace.shared.open(url)
		}
	}
}
