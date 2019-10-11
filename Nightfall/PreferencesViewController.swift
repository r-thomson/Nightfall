//
//  PreferencesViewController.swift
//  Nightfall
//
//  Created by Ryan Thomson on 11/27/18.
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
	@IBAction func openKeyboardPreferences(_ sender: NSButton) {
		let url = URL(fileURLWithPath: "/System/Library/PreferencePanes/Keyboard.prefPane")
		NSWorkspace.shared.open(url)
	}
	
}
