//
//  SearchViewController.swift
//  ImageToText
//
//  Created by Swamita on 22/09/20.
//

import UIKit
import Speech
import SafariServices

class SearchViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        micButton.isEnabled = false
        speechRecognizer!.delegate = self
            
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
                
            var isButtonEnabled = false
                
            switch authStatus { 
                case .authorized:
                    isButtonEnabled = true
                    
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                    
                case .restricted:
                    isButtonEnabled = false
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    isButtonEnabled = false
                    print("Speech recognition not yet authorized")
            @unknown default:
                fatalError("SF Speech recognition failed!")
            }
                
            OperationQueue.main.addOperation() {
                    self.micButton.isEnabled = isButtonEnabled
                }
        }
        
    }
    
    @IBAction func micTapped(_ sender: Any) {
        if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                micButton.isEnabled = false
            messageLabel.text = "Tap to Start Recording"
            } else {
                startRecording()
                messageLabel.text = "Tap to Stop Recording"
            }
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        if textView.text == "Say something, I'm listening!" {
            textView.text = "Speak on the microphone to record your request..."
        } else {
            explore(textView.text)
        }
        
    }
    
    //MARK: - Mic Functionalities
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.micButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            micButton.isEnabled = true
        } else {
            micButton.isEnabled = false
        }
    }
    
    //MARK: - Enter SafariVC
    
    func explore(_ topic: String) {
        let newStr = topic.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.google.com/search?q="+newStr
        if let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
    }
}
