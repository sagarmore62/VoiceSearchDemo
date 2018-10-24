//
//  ViewController.swift
//  VoiceSearchDemo
//
//  Created by Sagar More on 17/10/18.
//  Copyright © 2018 Sagar More. All rights reserved.
//

import UIKit
import Speech

protocol SearchDelegate : class {
    func onVoiceRecord(_ text : String)
}

class SearchViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var imgVoice : UIImageView!
    @IBOutlet var widthConstraint : NSLayoutConstraint!
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var btnRetry : UIButton!
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    private var request : SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask : SFSpeechRecognitionTask?
    private var animator : UIViewPropertyAnimator!
    private var timer : Timer?
    weak var delegate : SearchDelegate?
    private let errorString = "Didn't catch that. Try speaking again."
    private let speakNowString = "Speak Now!"
    private let timerTime : TimeInterval = 7.0
    private let isTimerEnabled = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRetry.isEnabled = false
        btnRetry.addTarget(self, action: #selector(retyClicked), for: .touchUpInside)
        createRequest()
        requestSpeechAuthorization()
        addTapGesture()
    }
    
    deinit {
        invalidateTimer()
    }
    
    private func invalidateTimer() {
        if let _ = timer {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Create request for speech recognition
    private func createRequest() {
        self.request = SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
    }
    
    private func createTimer() {
        invalidateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: timerTime, repeats: false, block: { [unowned self] (_) in
            self.showTryAgain()
        })
    }
    
    private func showTryAgain() {
        lblHeader.text = errorString
        imgVoice.layer.removeAllAnimations()
        btnRetry.isEnabled = true
    }
    
    // MARK: - Request for Speech authorization
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized :
                    self.recordStart()
                case .denied :
                    self.setHeader("Permission Denied")
                case .notDetermined :
                    self.setHeader("Permission Not Determined")
                case .restricted :
                    self.setHeader("Permission Restricted")
                }
            }
        }
    }

    // MARK: - Start recording after authorization is success
    func recordStart() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            //recognizer is not supported for current locale.
            return
        }
        if !myRecognizer.isAvailable {
            //recognizer not available right now
            return
        }
        
        createTimer()
        animateImage()
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                //successfuly received text from search.
                self.audioEngine.stop()
                self.request.endAudio()
                let bestString = result.bestTranscription.formattedString
                self.delegate?.onVoiceRecord(bestString)
                self.closeSelf()
            } else if let error = error {
                //Error occured in speech recognition
                print(error)
            }
        })
    }
    
    // MARK: - Add tappable gesture, to close controller
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.closeSelf))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Close view controller
    @objc private func closeSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Set Header text
    private func setHeader(_ text : String) {
        lblHeader.text = text
    }
    
    @objc private func retyClicked() {
        stopAudioEngine()
        createRequest()
        recordStart()
    }
    
    private func stopAudioEngine() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    // MARK: - Animate voice record image.
    private func animateImage() {
        btnRetry.isEnabled = false
        setHeader("Speak Now!")
        animate()
    }
    
    private func animate() {
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.8
        scaleAnimation.repeatCount = Float.greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 1.1
        imgVoice.layer.add(scaleAnimation, forKey: "scale")
    }

}

