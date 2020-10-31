//
//  ProfileViewController.swift
//  SoapboxNew
//
//  Created by Daniel Mesa on 10/30/20.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
