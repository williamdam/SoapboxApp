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
        
        setUpElements();

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
                    
                    // Print statements for debug
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("firstname") ?? "")
                    print(document.get("lastname") ?? "")
                    print(document.get("email") ?? "")
                    
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
    
}
