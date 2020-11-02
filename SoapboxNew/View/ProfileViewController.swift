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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                    
                    // Set First Name text field
                    self.firstNameTextField.text = (document.get("firstname") as! String)
                    
                    // Set First Name text field
                    self.lastNameTextField.text = (document.get("lastname") as! String)
                    
                    // Set Email text field
                    self.emailTextField.text = (document.get("email") as! String)
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

    @IBAction func LogOutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
        view.window?.rootViewController = welcomeViewController
        view.window?.makeKeyAndVisible()
    }
    
    
}
