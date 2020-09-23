//
//  SummaryViewController.swift
//  ImageToText
//
//  Created by Swamita on 23/09/20.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = "Hello world"
        copyButton.setTitle("Copied", for: .normal)
        
    }
}
