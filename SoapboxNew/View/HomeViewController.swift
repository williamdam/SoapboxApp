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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

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
    @IBOutlet weak var mainTextArea: UITextView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    

    // Create constant for location manager
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tap anywhere to dismiss keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Keyboard popup listener.  Calls function: keyboardWillShow()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Keyboard hide listener.  Calls function: KeyboardWillHide()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")

        // Do any additional setup after loading the view.
        // Get Firebase uid
        let userID = Auth.auth().currentUser!.uid
        print("User ID: " + userID)
        
        // Set location manager's delegate (self)
        locationManager.delegate = self
        
        // Prompt user for location service permission
        locationManager.requestWhenInUseAuthorization()
        
        // Start getting user's location only if authorized
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways){
                locationManager.startUpdatingLocation()
            }
        
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Create a reference to the "shouts" collection
        let shoutsDb = db.collection("shouts")
        
        // Query all documents from "shouts" collection
        shoutsDb.order(by: "epochTime").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("uid") ?? "")
                    print(document.get("message") ?? "")
                    print(document.get("latitude") ?? "")
                    print(document.get("longtitude") ?? "")
                    
                    
                    let latitude = document.get("latitude") as! Double
                    let longitude = document.get("longitude") as! Double
                    
                    let coordinate₀ = CLLocation(latitude: latitude, longitude: longitude)
                    let coordinate₁ = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)

                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles =  distanceInMeters * 0.000621371192;
                    
                    if distanceInMiles < 1.0000 {
                        let thisUsername:String = document.get("username") as! String
                        let thisMessage:String = document.get("message") as! String
                        let thisPhotoURL:String = document.get("photoURL") as! String
                        let thisID:String = document.get("uid") as! String
                        let postDate:String = document.get("date") as! String
                        let postTime:String = document.get("time") as! String
                        
                        self.posts.append(Post(id: thisID, author: thisUsername, text: thisMessage, photoURL: thisPhotoURL, date: postDate, time: postTime))
                    }
                }
            }
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.tableFooterView = UIView()
            
            self.tableView.reloadData()
            
            self.scrollToBottom()

            
        }

        
        
        
        
        
    }
    

    
    // Define delegate function locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            userLatitude = currentLocation.coordinate.latitude
            userLongitude = currentLocation.coordinate.longitude
            
            print("\(String(describing: index)): \(currentLocation)")
            print("Latitude: " + String(currentLocation.coordinate.latitude))
            print("Longitude: " + String(currentLocation.coordinate.longitude))
        }
    }
    
    @IBAction func locationButtonpressed(_ sender: UIButton) {
        
        self.transitionToHome()
        print("Home screen reloaded.")
    }
    
    // Send button pressed
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        print("DATE AND TIME")
        let date = Date()
        print(date)
        let epochTime = NSDate().timeIntervalSince1970
        print(epochTime)
        
        let formattedDate = DateFormatter()
        formattedDate.dateStyle = .short
        print(formattedDate.string(from: date))
        self.currentDate = formattedDate.string(from: date)
        
        let formattedTime = DateFormatter()
        formattedTime.timeStyle = .short
        print(formattedTime.string(from: date))
        self.currentTime = formattedTime.string(from: date)
        
        // Initialize Firestore connection
        let db = Firestore.firestore()
        
        // Get Firebase uid
        let userID = Auth.auth().currentUser!.uid
        print("User ID: " + userID)
        
        db.collection("users").whereField("uid", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print(document.get("username") ?? "")
                        self.currentUsername = document.get("username") as! String
                        self.photoURL = document.get("photoURL") as! String
                        print("Current Username: " + self.currentUsername)
                    }
                    
                    // Save message
                    let message = self.messageTextField.text!
                    
                    db.collection("shouts").addDocument(data: ["uid":userID, "username":self.currentUsername, "photoURL": self.photoURL, "message":message, "latitude":self.userLatitude, "longitude":self.userLongitude, "date":self.currentDate, "time":self.currentTime, "epochTime":epochTime]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data.")
                        } else {
                            // Go to Home Screen
                            self.transitionToHome()
                        }
                    }
                    
                    
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
    
    func scrollToBottom(){
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.posts.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    
}


