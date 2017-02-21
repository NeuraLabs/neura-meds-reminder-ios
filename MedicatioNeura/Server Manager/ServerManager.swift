//
//  ServerManager.swift
//  MedicatioNeura
//
//  Created by Youval Vaknin on 15/02/2017.
//  Copyright © 2017 neura. All rights reserved.
//

import Alamofire

class serverManager {
    
    #if DEBUG
        let serverUrl = "http://webhook.d.theneura-int.com"; //"http://192.168.5.39:3000"
    #else
        let serverUrl = "https://<some url>"
    #endif
    // Singleton
    static let manager = serverManager()
    
    func addUser(neuraToken: String, pushToken: String, completion: @escaping (Bool, String) -> ()) {
        self.userAction(URL: serverUrl + "/user", neuraToken: neuraToken, pushToken: pushToken, completion: completion)
    }
    
    private func userAction(URL: String, neuraToken: String, pushToken: String, completion: @escaping (Bool, String) -> ()) {
        let paramerters: Parameters = [
            "platform": "ios",
            "neura_token": neuraToken,
            "push_token": pushToken
        ]
        Alamofire.request(URL, method: .post, parameters: paramerters, encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result {
            case .success:
                guard
                    let info = response.result.value as? Dictionary<String, AnyObject>,
                    let oid = info["_id"] as? String else {
                        completion(false, "bad response")
                        return
                }
                completion(true, oid)
            case .failure:
                completion(false, response.description)
            }
        }
    }

}
