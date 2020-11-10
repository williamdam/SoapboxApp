//
//  HomeViewController.swift
//  SoapboxNew
//
//  Created by william dam on 10/26/20.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //add UITableView to Home storyboard
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        //register cell we made to table view
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:"postCell")
        view.addSubview(tableView)
        
        var layoutGuide: UILayoutGuide!
        layoutGuide = view.safeAreaLayoutGuide
        
        //add constraints
        tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true;
        tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true;
        tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true;
        tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true;
        
        //attach delegate to class
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        // to change table view cells, reload data.
        tableView.reloadData();
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell;
        
        return cell;
    }
    
    

}
