//
//  SignupViewController.swift
//  SoapboxNew
//
//  Created by william dam on 10/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tapToChangeButton: UIButton!
    var imagePicker:UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements(){
        
        //hide error label
        errorLabel.alpha = 0;
        //style text fields
        Utilities.styleFilledButton(signUpButton)
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true

        
        //instantiate image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    @objc func openImagePicker(_sender:Any){
        //open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Check fields and return nil on success, or error message string
    func validateFields() -> String? {
        
        // Check all fields are filled in
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        // Check password is secure

        return nil
    }

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        // Validate Fields
        let error = validateFields()
        
        if error != nil {
            
            // Alert field verification fail
            showError(error!)
        }
        else {
            // Create User
            
            // Create cleaned versions of data
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let image = profileImageView.image else {return}
            
            // Create Firebase user login
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // Error creating user
                    self.showError("Error creating user.")
                }
                else {
                    
                    // Upload the profile image to Firebase Storage
                    self.uploadProfileImage(image) { url in
                        if url != nil{
                            
                            // Create user profile in Firestore database
                            let db = Firestore.firestore()
                            db.collection("users").addDocument(data: ["username":username, "firstname":firstName, "lastname":lastName, "email":email, "photoURL":url!.absoluteString ,"uid": result!.user.uid]) { (error) in
                                
                                if error != nil {
                                    // Show error message
                                    self.showError("Error saving user data.")
                                }else{
                                    // Go to Home Screen
                                    self.transitionToHome()
                                }
                            }
                        }else{
                            self.showError("Error saving user data.")
                        }

                    }
                }
            }
        }
        
        
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {

                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                }
                } else {
                    // failed
                    completion(nil)
                }
            }
    }
    
    
    func showError(_ message: String) {
        errorLabel.alpha = 1
        errorLabel.text = message
        
    }
    
    func transitionToHome() {
        let homeViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController)as! HomeViewController
        let navigationController = UINavigationController (rootViewController: homeViewController)
        self.present(navigationController, animated: false, completion: nil)
    }
    
}
extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
    
    

