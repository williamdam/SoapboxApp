//
//  LoginViewController.swift
//  SoapboxNew
//
//  Created by william dam on 10/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        Utilities.styleFilledButton(loginButton)
    }
    
    func showError(_ message: String) {
        errorLabel.alpha = 1
        errorLabel.text = message
        
    }
    

    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        
        // To do: Validate text fields
        
        // Create cleaned versions of text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sign in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                
                self.showError("The email and/or password does not match our records. Please try again.")
            }
            else {
                let homeViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController)as! HomeViewController
                let navigationController = UINavigationController (rootViewController: homeViewController)
                self.present(navigationController, animated: false, completion: nil)
            }
        }
        
    }
    
}
