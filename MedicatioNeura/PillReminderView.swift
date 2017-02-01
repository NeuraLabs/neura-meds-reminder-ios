//
//  PillReminderView.swift
//  MedicatioNeura
//
//  Created by Youval Vaknin on 29/12/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import Foundation
import UIKit
import NeuraSDK

class PillReminderView: UIView {
    
    //MARK: Properties

    @IBOutlet weak var TimeImageView: UIImageView!
    @IBOutlet weak var TimeHeadlineLabel: UILabel!
    @IBOutlet weak var TimeSubHeadlineLabel: UILabel!
    @IBOutlet weak var TookLabel: CustomLabel!
    @IBOutlet weak var MissedLabel: CustomLabel!
    @IBOutlet weak var ProgressView: UIView!
    @IBOutlet weak var LearningProgressBar: UIProgressView!
    
    class func instanceFromNib(imageName: String, headline: String, subHeadline: String, takenCount: String?, missedCount: String?) -> PillReminderView {
        
        let returnView = setProps(imageName: imageName, headline: headline, subHeadline: subHeadline)
        returnView.TookLabel.text = takenCount ?? "\(0)"
        returnView.MissedLabel.text = missedCount ?? "\(0)"
        
        return returnView
    }
    
    class func setProps(imageName: String, headline: String, subHeadline: String) -> PillReminderView {
        let returnView = UINib(nibName: "PillReminderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PillReminderView
        returnView.TimeHeadlineLabel.text = headline
        returnView.TimeSubHeadlineLabel.text = subHeadline
        returnView.TimeImageView.image = UIImage.init(named: imageName)
        
        return returnView
    }
    
    func updateView(progressValue: Float) {
        
        self.LearningProgressBar.progress = progressValue
        
        self.ProgressView.alpha = 1.0
        self.TimeImageView.alpha = 0.1
        self.TimeHeadlineLabel.alpha = 0.1
        self.TimeSubHeadlineLabel.alpha = 0.1
        self.TookLabel.alpha = 0.1
        self.MissedLabel.alpha = 0.1
    }
}
