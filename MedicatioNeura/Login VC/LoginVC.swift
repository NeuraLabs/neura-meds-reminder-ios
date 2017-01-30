//
//  LoginVC.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 23/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit
import NeuraSDK

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var loginButton: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        NeuraSDKManager.manager.login(viewController: self, callback: { success, error in
        
            if success == false {
                self.showError(error!)
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if NeuraSDKManager.manager.IsUserLogin() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "main") as! MainVC
                    UIApplication.shared.keyWindow?.rootViewController = initialViewController
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            }
        })
    }
    
    func showError(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
