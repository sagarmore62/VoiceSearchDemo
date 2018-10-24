//
//  RootViewController.swift
//  VoiceSearchDemo
//
//  Created by Sagar More on 23/10/18.
//  Copyright © 2018 Sagar More. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, SearchDelegate  {

    @IBOutlet weak var lblVoiceText : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func showSearchPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchViewController") as? SearchViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Delegate method of search
    func onVoiceRecord(_ text : String) {
        lblVoiceText.text = text
    }
}
