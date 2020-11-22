//
//  ProfileViewController.swift
//  SoapboxNew
//
//  Created by Daniel Mesa on 10/30/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var imagePicker:UIImagePickerController!
    
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
        self.formStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.formStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        
        // Set width of stack view to scroll view
        self.formStackView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -40.0).isActive = true
        
        setUpElements()

        // Hide error label
        errorMessageLabel.alpha = 0
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Get Firebase uid
        let userID = Auth.auth().currentUser!.uid
        print("User ID: " + userID)
        
        // Get data from "users" collection
        db.collection("users").whereField("uid", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    // Set Username text label
                    self.usernameLabel.text = ((document.get("username") ?? "") as! String)
                    
                    // Set First Name text field
                    self.firstNameTextField.text = (document.get("firstname") as! String)
                    
                    // Set First Name text field
                    self.lastNameTextField.text = (document.get("lastname") as! String)
                    
                    // Set Email text field
                    self.emailTextField.text = (document.get("email") as! String)
                
                    
                    //set profile image
                    let url = URL(string: document.get("photoURL") as! String);
                    ImageService.getImage(withURL: url!){
                        image in self.profileImageView.image = image
                    }
                }
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setUpElements(){
        
        //hide error label
        errorMessageLabel.alpha = 0;
        //style text fields
        Utilities.styleFilledButton(saveChangesButton)
        
        //set profile image details
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true

        
    }
    

    // Check fields and return nil on success, or error message string
    func validateFields() -> String? {
        
        // Check all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        return nil
    }
    
    func showError(_ message: String) {
        errorMessageLabel.alpha = 1
        errorMessageLabel.text = message
        
    }
    
    @IBAction func saveChangesButtonPressed(_ sender: UIButton) {
                
        if self.validateFields() != nil {
            let fieldError = validateFields()
            showError(fieldError!)
        }
        else {
            
            // Create cleaned versions of data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Initialize database
            let db = Firestore.firestore()
            
            // Get Firebase uid
            let userID = Auth.auth().currentUser!.uid
            print("User ID: " + userID)
            
            // Get data from "users" collection with uid
            db.collection("users").whereField("uid", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let docID = document.documentID
                        let userDocument = db.collection("users").document(docID)
                        
                        userDocument.updateData([
                            "firstname": firstName,
                            "lastname": lastName,
                            "email": email
                        ]) { err in
                            if let err = err {
                                print("Error updating user profile: \(err)")
                                self.showError("Error updating user profile.")
                            } else {
                                print("Profile successfully updated!")
                                self.showError("Profile successfully updated!")
                            }
                        }

                    }
                }
            }
        }
        
    }
    
    @IBAction func LogOutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
        view.window?.rootViewController = welcomeViewController
        view.window?.makeKeyAndVisible()
    }
    
    // Function sets stack view bottom constraint to keyboard frame height
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
    
}
