//
//  SideBarVC.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 16/12/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit

class SideBarVC: UIViewController {
    
    @IBOutlet weak var shareButton: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let neuraColor: UIColor = UIColor(red: 0.000, green: 0.796, blue: 1.000, alpha: 1.000)
        
        shareButton.backgroundColor = neuraColor
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.view.frame.size
        gradient.colors = [neuraColor,UIColor.white.cgColor]
        self.view.layer.addSublayer(gradient)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        let message = "Hi, you have been invited to access a Neura SDK configuration which was created to enhance your product by supporting the following features:\n        \n        • Personal Morning Medication Reminder\n        Perfectly timed to when each user wakes up\n        •  Don\'t leave your pillbox behind Call to action\n        When the user leaves home\n        •  Predictive Bedtime Pill Reminder\n        Approach the user before he goes to bed\n        \n        Get started with the sdk: https://dev.theneura.com/v/medical_adherence/new\n        Experience and share the demo with your team: https://play.google.com/store/apps/details?id=com.neura.medsreminder\n        Get the open source add on for med adherence : https://github.com/NeuraLabs/MedicatioNeurAndroid\n        Learn how Neura is specifically tailored to enhance medical adherence solutions: http://www.theneura.com/med-adherence\n        \n        About Neura\n        Neura\'s AI service enables apps and devices to boost engagement by reacting to moments in each user’s day-to-day life.\n        •  1 hour integration\n        •  88% increase in engagement\n        •  Enhance your product with Artificial Intelligence"
        
        //        if let link = NSURL(string: "http://www.theneura.com/med-adherence") {
        //            let objectsToShare = [message,link] as [Any]
        
//        let df = UIActivityItemSource.
        let objectsToShare = [message] as [Any]
        
        
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.title = "Check out Neura's SDK, looks useful"
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
        //        }
    }
    
    
}
