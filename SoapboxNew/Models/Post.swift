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
    var date: String
    var time: String
    
    init(id:String, author:String, text:String, photoURL:String, date:String, time:String){
        self.id = id
        self.author = author
        self.text = text
        self.photoURL = photoURL
        self.date = date
        self.time = time
    }
}
