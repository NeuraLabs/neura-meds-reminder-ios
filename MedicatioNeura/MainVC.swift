//
//  MainVC.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 21/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit
import NeuraSDK

class MainVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideBarContainer: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var morningTookLabel: CustomLabel!
    @IBOutlet weak var morningMissedLabel: CustomLabel!
    @IBOutlet weak var eveningTookLabel: CustomLabel!
    @IBOutlet weak var eveningMissedLabel: CustomLabel!
    @IBOutlet weak var takeTookLabel: CustomLabel!
    @IBOutlet weak var takeMissedLabel: CustomLabel!
    
    @IBOutlet weak var showSideBarButton: UIButton!
    
    
    //MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.willEnterForeground()
        
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowRadius = 10
        self.mainView.layer.shadowOpacity = 0.3
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func willEnterForeground() {
        welcomeLabel.text = NeuraSDKManager.manager.greetingMessage()
        
        setCountLabels()
        
        if NeuraSDKManager.manager.eveningPillsProgress() > 2 {
            self.progressView.alpha = 0
            
        } else {
            self.progressBar.progress = Float(NeuraSDKManager.manager.eveningPillsProgress()) / 2
        }
    }
    
    
    func setCountLabels() {
        self.morningTookLabel.text = UserDefaults.standard.string(forKey: kMorningTookCount)
        self.eveningTookLabel.text = UserDefaults.standard.string(forKey: kEveningTookCount)
        self.takeTookLabel.text = UserDefaults.standard.string(forKey: kPillboxTookCount)
        
        self.morningMissedLabel.text = UserDefaults.standard.string(forKey: kMorningMissedCount)
        self.eveningMissedLabel.text = UserDefaults.standard.string(forKey: kEveningMissedCount)
        self.takeMissedLabel.text = UserDefaults.standard.string(forKey: kPillboxMissedCount)
    }
    
    
    
    func isSideBarRevealed() -> Bool {
        return self.mainView.frame.origin.x < 0
        
    }
    
    func toggleSideBar() {
        let tX = -view.frame.size.width + 80
        var t = CGAffineTransform(translationX:tX, y: 0)
        var r = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        
        if self.isSideBarRevealed() {
            t = CGAffineTransform(translationX:0, y: 0)
            r = CGAffineTransform(rotationAngle: 0)
        }
        
        UIView.animate(withDuration: 0.4) {
            self.mainView.transform = t
            self.showSideBarButton.transform = r
        }
    }
    
    
    
    //MARK: IBAction Functions
    @IBAction func showSideBarButtonPressed(_ sender: Any) {
        self.toggleSideBar()
    }
    
    
    @IBAction func onSwipedRight(_ sender: Any) {
        if self.isSideBarRevealed() {
            self.toggleSideBar()
        }
    }
    
    
    
}

