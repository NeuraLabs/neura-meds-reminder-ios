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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideBarContainer: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var showSideBarButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    var MorningView: PillReminderView!
    var EveningView: PillReminderView!
    var PillBoxView: PillReminderView!
    
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
        
        if NeuraSDKManager.manager.eveningPillsProgress() <= 2 {
            self.EveningView.updateView(progressValue: Float(NeuraSDKManager.manager.eveningPillsProgress()) / 2)
        }
    }
    
    func setCountLabels() {
        self.MorningView = PillReminderView.instanceFromNib(imageName:"morningiconsmall", headline: "Morning Pills Reminder", subHeadline: "Get reminded to take your pills when you wake up", takenCount: UserDefaults.standard.string(forKey: kMorningTookCount), missedCount: UserDefaults.standard.string(forKey: kMorningMissedCount))
        self.EveningView = PillReminderView.instanceFromNib(imageName:"eveningiconsmall", headline: "Evening Pills Reminder", subHeadline: "Get reminded to take your pills when you go to sleep", takenCount: UserDefaults.standard.string(forKey: kEveningTookCount), missedCount: UserDefaults.standard.string(forKey: kEveningMissedCount))
        self.PillBoxView = PillReminderView.instanceFromNib(imageName:"pillboxiconsmall", headline: "Med Box Reminder", subHeadline: "Get reminded to take your pillbox with you when you leave home", takenCount: UserDefaults.standard.string(forKey: kPillboxTookCount), missedCount: UserDefaults.standard.string(forKey: kPillboxMissedCount))
        
        let borderViewMorning = UIView()
        borderViewMorning.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        borderViewMorning.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewMorning, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 1)])
        self.MorningView.addSubview(borderViewMorning)
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewMorning, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.MorningView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -1)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewMorning, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.MorningView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewMorning, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.MorningView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)])

        let borderViewEvening = UIView()
        borderViewEvening.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        borderViewEvening.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewEvening, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 1)])
        self.EveningView.addSubview(borderViewEvening)
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewEvening, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.EveningView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -1)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewEvening, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.EveningView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: borderViewEvening, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.EveningView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)])

        self.stackView.addArrangedSubview(self.MorningView)
        self.stackView.addArrangedSubview(self.EveningView)
        self.stackView.addArrangedSubview(self.PillBoxView)
        
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

