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

    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Swipe up anywhere on screen to dismiss keyboard
        scrollView.keyboardDismissMode = .onDrag
        
        // Keyboard popup listener.  Calls function: keyboardWillShow()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Keyboard hide listener.  Calls function: KeyboardWillHide()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add stack view as subview to scroll view
        self.scrollView.addSubview(formStackView)
        
        // Constraints to be added in code
        self.formStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bind stack view at all sides to scroll view
        self.formStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        self.formStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: 20.0).isActive = true
        self.formStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 20.0).isActive = true
        self.formStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        
        // Set width of stack view to scroll view
        self.formStackView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -40.0).isActive = true
        
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let info = notification.userInfo {
            
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations:  {
                self.view.layoutIfNeeded()
                self.scrollViewBottomConstraint.constant = rect.height
                
                
            })
        }
    }
    
    // Function sets stack view bottom constraint to zero
    @objc func keyboardWillHide(notification: NSNotification) {
      
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
            self.scrollViewBottomConstraint.constant = 0
        })
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
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: false, completion: nil)
                
            }
        }
        
    }
    
}
