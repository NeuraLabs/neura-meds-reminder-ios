//
//  CustomButton.swift
//  MedicatioNeura
//
//  Created by Youval Vaknin on 23/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.bounds.height / 4
    }
}
