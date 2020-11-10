//
//  HomeViewController.swift
//  SoapboxNew
//
//  Created by william dam on 10/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    var username:String?
    var userLatitude = 0.0
    var userLongitude = 0.0
    var shoutsText:String = ""
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var mainTextArea: UITextView!
    
    // Create constant for location manager
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Create a reference to the shouts collection
        let shoutsDb = db.collection("shouts")
        
        // Query all documents from "shouts" collection
        shoutsDb.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("uid") ?? "")
                    print(document.get("message") ?? "")
                    print(document.get("latitude") ?? "")
                    print(document.get("longtitude") ?? "")
                }
            }
        }
        
        // Get Firebase uid
        let userID = Auth.auth().currentUser!.uid
        print("User ID: " + userID)
        
        // Set location manager's delegate (self)
        locationManager.delegate = self
        
        // Prompt user for location service permission
        locationManager.requestWhenInUseAuthorization()
        
        // Start getting user's location
        locationManager.startUpdatingLocation()
        
    }
    

    /*
    // MARK: - Navigation//

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Define delegate functio locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            userLatitude = currentLocation.coordinate.latitude
            userLongitude = currentLocation.coordinate.longitude
            
            print("\(String(describing: index)): \(currentLocation)")
            print("Latitude: " + String(currentLocation.coordinate.latitude))
            print("Longitude: " + String(currentLocation.coordinate.longitude))
        }
    }
    
    // Send button pressed
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Get Firebase uid
        let userID = Auth.auth().currentUser!.uid
        print("User ID: " + userID)
        
        // Save username
        
        // Save message
        let message = messageTextField.text!
        
        db.collection("shouts").addDocument(data: ["uid":userID, "message":message, "latitude":userLatitude, "longitude":userLongitude]) { (error) in
            
            if error != nil {
                // Show error message
                self.showError("Error saving user data.")
            } else{
                // Go to Home Screen
                self.transitionToHome()
            }
        }
        
    }
    
    func showError(_ message: String) {
        // errorLabel.alpha = 1
        // errorLabel.text = message
        print("Error: " + message)
        
    }
    
    func transitionToHome() {
        let homeViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController)as! HomeViewController
        let navigationController = UINavigationController (rootViewController: homeViewController)
        self.present(navigationController, animated: false, completion: nil)
    }
}
