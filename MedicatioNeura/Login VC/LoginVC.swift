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
    
    weak var mainVCDelegate: MainVCProtocol?
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
            
            if NeuraSDKManager.manager.IsUserLogin() {
                    self.mainVCDelegate?.loginFinished()
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
