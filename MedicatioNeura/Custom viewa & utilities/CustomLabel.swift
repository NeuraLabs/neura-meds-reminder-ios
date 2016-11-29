//
//  CustomLabel.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 14/12/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderWidth = 1;
        self.layer.borderColor = self.textColor.cgColor
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
