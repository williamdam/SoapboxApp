//
//  Utilities.swift
//  SoapboxNew
//
//  Created by Daniel Mesa on 10/26/20.
//

import Foundation
import UIKit


class Utilities {

    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}
