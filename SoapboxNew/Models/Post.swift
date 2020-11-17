//
//  Post.swift
//  SoapboxNew
//
//  Created by Daniel Mesa on 11/16/20.
//

import Foundation

class Post{
    var id:String
    var author: String
    var text: String
    var photoURL: String
    
    init(id:String, author:String, text:String, photoURL:String){
        self.id = id
        self.author = author
        self.text = text
        self.photoURL = photoURL
    }
}
