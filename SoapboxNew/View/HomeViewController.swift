//
//  HomeViewController.swift
//  Soapbox
//
//  Created by william dam on 10/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    var userID = ""
    var currentUsername = ""
    var photoURL = ""
    var userLatitude = 0.0
    var userLongitude = 0.0
    var posts = [Post]()
    var currentDate = ""
    var currentTime = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    // Create constant for location manager
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Swipe up anywhere on screen to dismiss keyboard
        tableView.keyboardDismissMode = .onDrag
        
        // Keyboard popup listener.  Calls function: keyboardWillShow()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Keyboard hide listener.  Calls function: KeyboardWillHide()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        // Get Firebase uid
        userID = Auth.auth().currentUser!.uid
        //print("User ID: " + userID)
        
        // Set location manager's delegate (self)
        locationManager.delegate = self
        
        // Prompt user for location service permission
        locationManager.requestWhenInUseAuthorization()
        
        // Start getting user's location only if authorized
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            locationManager.startUpdatingLocation()
        }
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Start listening for changes in shouts collection
        db.collection("shouts").order(by: "epochTime").addSnapshotListener { querySnapshot, error in
                
            guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New post: \(diff.document.data())")
                    let shoutLatitude = diff.document.get("latitude") as! Double
                    let shoutLongitude = diff.document.get("longitude") as! Double
                    
                    let coordinate₀ = CLLocation(latitude: shoutLatitude, longitude: shoutLongitude)
                    let coordinate₁ = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)

                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles =  distanceInMeters * 0.000621371192;
                    
                    // Get seconds elapsed from time of each post
                    let ageOfPost = NSDate().timeIntervalSince1970 - (diff.document.get("epochTime") as! Double)
                    
                    // Get posts within 1 mile radius and < 24 hours old
                    if distanceInMiles < 1.0000 && ageOfPost < 86400 {
                        let thisUsername:String = diff.document.get("username") as! String
                        let thisMessage:String = diff.document.get("message") as! String
                        let thisPhotoURL:String = diff.document.get("photoURL") as! String
                        let thisID:String = diff.document.get("uid") as! String
                        let postDate:String = diff.document.get("date") as! String
                        let postTime:String = diff.document.get("time") as! String
                        
                        self.posts.append(Post(id: thisID, author: thisUsername, text: thisMessage, photoURL: thisPhotoURL, date: postDate, time: postTime))
                    }
                }
                if (diff.type == .modified) {
                    print("Modified post: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed post: \(diff.document.data())")
                }
            }
            
            
            self.tableView.reloadData()
            self.scrollToBottom()
            
        }
        
        
    }
    
    // Define delegate function locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for currentLocation in locations {
            userLatitude = currentLocation.coordinate.latitude
            userLongitude = currentLocation.coordinate.longitude
        }
        
    }
    
    // Refresh button pressed.  Reload home screen.
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        
        self.tableView.reloadData()
        self.scrollToBottom()
        print("Home screen reloaded.")
    }
    
    // Send button pressed
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        //print("DATE AND TIME")
        let date = Date()
        //print(date)
        
        // Get Unix time (seconds) since 00:00:00 UTC on 1 January 1970
        let epochTime = NSDate().timeIntervalSince1970
        
        // Set current date in readable format
        let formattedDate = DateFormatter()
        formattedDate.dateStyle = .short
        //print(formattedDate.string(from: date))
        self.currentDate = formattedDate.string(from: date)
        
        // Set current time in readable format
        let formattedTime = DateFormatter()
        formattedTime.timeStyle = .short
        //print(formattedTime.string(from: date))
        self.currentTime = formattedTime.string(from: date)
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Post new shout to message board
        db.collection("users").whereField("uid", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    
                    // Save username and profile photo to variables
                    for document in querySnapshot!.documents {
                        self.currentUsername = document.get("username") as! String
                        self.photoURL = document.get("photoURL") as! String
                        //print("Current Username: " + self.currentUsername)
                    }
                    
                    // Save message to this variable
                    let message = self.messageTextField.text!
                    
                    // Post message.  Add Firestore document with data below.
                    db.collection("shouts").addDocument(data: ["uid":self.userID, "username":self.currentUsername, "photoURL": self.photoURL, "message":message, "latitude":self.userLatitude, "longitude":self.userLongitude, "date":self.currentDate, "time":self.currentTime, "epochTime":epochTime]) { (error) in
                        
                        // Error handling
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data.")
                        }
                        else {
                            
                            self.messageTextField.text = ""
                            // Go to Home Screen
                            //self.transitionToHome()
                        }
                        
                    }
                    
                }
        }
        
    }   // End IBAction sendButtonPressed
    
    // Error handling function
    func showError(_ message: String) {
        // errorLabel.alpha = 1
        // errorLabel.text = message
        print("Error: " + message)
        
    }
    
    // Load home view controller (deprecated)
    func transitionToHome() {
        let homeViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController)as! HomeViewController
        let navigationController = UINavigationController (rootViewController: homeViewController)
        self.present(navigationController, animated: false, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        cell.set(post: posts[indexPath.row])
        return cell
    }
    
    // Function sets stack view bottom constraint to keyboard frame height
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let info = notification.userInfo {
            
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations:  {
                self.view.layoutIfNeeded()
                self.stackViewBottomConstraint.constant = rect.height
            })
        }
    }
    
    // Function sets stack view bottom constraint to zero
    @objc func keyboardWillHide(notification: NSNotification) {
      
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
            self.stackViewBottomConstraint.constant = 0
        })
    }
    
    // Function scrolls tableView to bottom message
    func scrollToBottom(){
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.posts.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    
}


