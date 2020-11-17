//
//  PostTableViewCell.swift
//  SoapboxNew
//
//  Created by Daniel Mesa on 11/9/20.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //round the image profile view
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(post:Post){
        let url = URL(string: post.photoURL)
        ImageService.downloadImage(withURL: url! ){
            image in self.profileImageView.image = image
            
        }
        usernameLabel.text = post.author
        postTextLabel.text = post.text
        subtitleLabel.text = post.date + " at " + post.time

    }
    

    
}
