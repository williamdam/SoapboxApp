//
//  ViewController.swift
//  SoapboxNew
//
//  Created by william dam on 10/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Check if user is signed in
        Auth.auth().addStateDidChangeListener { auth, user in
          if user != nil {
            print("User already logged in.")
            
            // User is signed in. Show home screen
            let homeViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
            let navigationController = UINavigationController (rootViewController: homeViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: false, completion: nil)
          }
          else {
            print("No user logged in.")
            // No User is signed in. Show user the login screen
            self.setUpElements()
          }
        }
        
        
        
    }
    
    func setUpElements(){
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleFilledButton(loginButton)
    }


}

