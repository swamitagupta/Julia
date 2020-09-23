//
//  ViewController.swift
//  ImageToText
//
//  Created by Swamita on 22/09/20.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var image  = UIImage(named: "sample")
    var textString = ""
    var text = ""

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    let imagePicker = UIImagePickerController()
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.isHidden = true
        self.activity.stopAnimating()
        imagePicker.delegate = self
        
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Import Image", message: "From where do you want to import your image?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Capture from Camera", style: .default, handler: { action in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(named: "AlertGolden")
        self.present(alert, animated: true)
    }
    
    //MARK: - Text to Speech
    
    let synthesizer = AVSpeechSynthesizer()
    
    @IBAction func voiceTapped(_ sender: Any) {
        
         if (synthesizer.isPaused) {
            synthesizer.continueSpeaking();
                }
         else if (synthesizer.isSpeaking) {
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
                 }
        else if (!synthesizer.isSpeaking) {
            let utterance = AVSpeechUtterance(string: textView.text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            synthesizer.speak(utterance)
                 }

    }
    
    //MARK: - Summarize
    
    @IBAction func summaryTapped(_ sender: Any) {
        
        let summary = Summary()
        let content = textView.text!
        let summarisedContent = summary.getSummary(content: content)
        text = summarisedContent.description
        
        performSegue(withIdentifier: "textToSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SummaryViewController
        vc.text = text
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
                self.textString += " \(topCandidate.string)"
                DispatchQueue.main.async {
                    self.textView.text = self.textString
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

//MARK: - UI ImagePicker Methods

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("Failed to load image!") }
        image = uiImage
        imageView.image = image
        imagePicker.dismiss(animated: true, completion: nil)
        
        activity.isHidden = false
        activity.startAnimating()
        self.textView.text = ""
        recognizeText(image: image!)
    }
}
