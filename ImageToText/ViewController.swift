//
//  ViewController.swift
//  ImageToText
//
//  Created by Swamita on 22/09/20.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController {
    
    let image  = UIImage(named: "sample")
    var textString = ""

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.isHidden = true
        self.activity.stopAnimating()
    }
    @IBAction func cameraTapped(_ sender: Any) {
        activity.isHidden = false
        activity.startAnimating()
        self.textView.text = ""
        recognizeText(image: image!)
    }
    
    //MARK: - Text to Speech
    
    @IBAction func voiceTapped(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    //MARK: - Extract text using Vision
    
    private func recognizeText(image: UIImage) {
        textString = ""
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation]
            else {
                fatalError("Invalid Observation")
            }
            for observation in observations{
                guard let topCandidate = observation.topCandidates(1).first
                else {print("No candidate")
                    continue
                }
                self.textString += "\n\(topCandidate.string)"
                DispatchQueue.main.async {
                    self.textView.text = self.textString
                    //self.textView.text = "akyzsfncklxduncubsgy"
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                }
            }
        })
        
        request.customWords = ["custom"]
        request.minimumTextHeight = 0.032
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image.cgImage else {
                fatalError("Cant scan")
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
        }
    }
}

