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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        let message =
        "Hi, you have been invited to access a Neura SDK configuration which was created to enhance your product by supporting the following features:\n\n" +
        "• Personal Morning Medication Reminder perfectly timed to when each user wakes up\n" +
        "•  Don\'t leave your pillbox behind Call to action when the user leaves home\n" +
        "•  Predictive Bedtime Pill Reminder. Approach the user before she/he goes to bed\n\n" +
        "Get started with the sdk: https://dev.theneura.com/wizard/med-adherence/new\n" +
        "Experience and share the demo with your team:\nhttps://itunes.apple.com/us/app/medicationeura/id1187915753?ls=1&mt=8\n" +
        "Get the open source add on for med adherence:\nhttps://github.com/NeuraLabs/NeuraMedsReminderIOS_Addon\n" +
        "Learn how Neura is specifically tailored to enhance medical adherence solutions:\nhttps://www.theneura.com/med-adherence\n\n" +
        "About Neura\nNeura\'s AI service enables apps and devices to boost engagement by reacting to moments in each user’s day-to-day life.\n" +
        "•  1 hour integration\n" +
        "•  88% increase in engagement\n" +
        "•  Enhance your product with Artificial Intelligence"
        
        let objectsToShare = [message] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.title = "Check out Neura's SDK, looks useful"
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
}
