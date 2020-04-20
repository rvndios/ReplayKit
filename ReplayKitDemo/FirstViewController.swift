//
//  FirstViewController.swift
//  ReplayKitDemo
//
//  Created by user on 20/04/20.
//  Copyright © 2020 Aravind. All rights reserved.
//

import UIKit
import ReplayKit
class FirstViewController: UIViewController {
    var recorder = RPScreenRecorder.shared()
    let controller = RPBroadcastController()
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var viewDance: UIView!
    var gradientLayer: CAGradientLayer!
    var isBroadcast = false
    var isRecording = false
    var timer: Timer!
    var prevColor = UIColor.red
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        recorder.isMicrophoneEnabled = true
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        self.viewDance.layer.insertSublayer(gradientLayer, at: 0)
    }
    @IBAction func startAction(_ sender: UIButton) {
        _ = isBroadcast ? startBroadCast() : startRecording()
    }
    @IBAction func stopAction(_ sender: UIButton) {
        stopDance()
        if isBroadcast {
            controller.finishBroadcast { error in
                if error == nil {
                    "Broadcast ended".po()
                    self.isRecording = false
                    self.startButton.isSelected = false
                }
            }
        } else {
            if isRecording {
                recorder.stopRecording { (preview, error) in
                    guard preview != nil else {
                        "It's Simulator So,Preview is not available.".po()
                        return
                    }
                    self.isRecording = false
                    self.startButton.isSelected = false
                }
            }
        }
    }
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        isBroadcast = sender.selectedSegmentIndex == 1
    }
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
}
extension FirstViewController: RPBroadcastActivityViewControllerDelegate {
    func danceNow() {
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(setRandomBackgroundColor), userInfo: nil, repeats: true)
        self.setRandomBackgroundColor()
    }
    func stopDance() {
        timer.invalidate()
        self.gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
    }
    @objc func setRandomBackgroundColor() {
         gradientLayer.frame = self.viewDance.bounds
        let colors = [
            UIColor(red: 233/255, green: 203/255, blue: 198/255, alpha: 1),
            UIColor(red: 38/255, green: 188/255, blue: 192/255, alpha: 1),
            UIColor(red: 253/255, green: 221/255, blue: 164/255, alpha: 1),
            UIColor(red: 235/255, green: 154/255, blue: 171/255, alpha: 1),
            UIColor(red: 87/255, green: 141/255, blue: 155/255, alpha: 1)
        ]
        let randomColor = Int(arc4random_uniform(UInt32 (colors.count)))
        gradientLayer.colors = [colors[randomColor].cgColor, prevColor.cgColor]
        prevColor = colors[randomColor]
       // self.viewDance.backgroundColor = colors[randomColor]
    }
    func startRecording() {
        if !isRecording {
            guard recorder.isAvailable else {
                "OOOPS! Recording is not available.".po()
                return
            }
            // Begin
            recorder.startRecording { (error) in
                guard error == nil else {
                    "Noo! There was an error starting the recording.".po()
                    return
                }
                self.danceNow()
                self.isRecording = true
                self.startButton.isSelected = true
            }
        }
    }
    func startBroadCast() {
        if !controller.isBroadcasting {
            RPBroadcastActivityViewController.load { broadcastAVC, error in
                guard error == nil else {
                    "HO oh! Cannot load Broadcast Activity View Controller.".po()
                    return
                }
                if let broadcastAVC = broadcastAVC {
                    broadcastAVC.delegate = self
                    self.present(broadcastAVC, animated: true, completion: nil)
                }
            }
        }
    }
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController,
                                         didFinishWith broadcastController: RPBroadcastController?,
                                         error: Error?) {
        guard error == nil else {
            "OOPS! Broadcast Activity Controller is not available.".po()
            return
        }
        broadcastActivityViewController.dismiss(animated: true) {
            broadcastController?.startBroadcast { error in
                //TODO: Broadcast might take a few seconds to load up. I recommend that you add an activity indicator or something similar to show the user that it is loading.
                if error == nil {
                    "Yay! Broadcast started!".po()
                    self.danceNow()
                    self.isRecording = true
                    self.startButton.isSelected = true
                }
            }
        }
    }
}





