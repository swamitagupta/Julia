//
//  SummaryViewController.swift
//  ImageToText
//
//  Created by Swamita on 23/09/20.
//

import UIKit

class SummaryViewController: UIViewController {
    
    var text = ""
    
    let summary = Summary()

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let summarisedContent = summary.getSummary(content: text)
        textView.text = summarisedContent.description
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = textView.text
        copyButton.setTitle("Copied", for: .normal)
        
    }
}
