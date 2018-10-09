//
//  NewsHelper.swift
//  project
//
//  Created by Stanislav Korolev on 22.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import Firebase

extension NewsController {

    // без отслеживания обновлений
    func getNewsONCE(){
        
        if self.currentKey == nil{
            
            Database.database().reference().child("news").queryOrdered(byChild: "timestamp").queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snap:DataSnapshot) in
                
                    if snap.childrenCount > 0 {
                        
                        let first = snap.children.allObjects.first as! DataSnapshot
                        
                        for s in snap.children.allObjects as! [DataSnapshot]{
                            let dictionary = s.value as! [String : AnyObject]
                            
                            let anews = News()
                            
                            anews.timestamp = dictionary["timestamp"] as? Double
                            anews.title = dictionary["title"] as? String
                            anews.text = dictionary["text"] as? String
                            
                            self.news.insert(anews, at: 0)
                            print(dictionary)
                        }
                        
                        self.currentKey = first.key
                        self.currentTimestamp = (first.value as! [String : AnyObject])["timestamp"] as! Double
                        print(self.currentTimestamp)
                        
                        self.collectionView?.reloadData()
                    }
            }
        }
        else{
            
            Database.database().reference().child("news").queryOrdered(byChild: "timestamp").queryEnding(atValue: self.currentTimestamp).queryLimited(toLast: 6).observeSingleEvent(of: .value , with: { (snap:DataSnapshot) in
                
                
                let index = self.news.count
                
                if snap.childrenCount > 0 {
                    
                    let first = snap.children.allObjects.first as! DataSnapshot
                    
                    for s in snap.children.allObjects as! [DataSnapshot]{
                        let dictionary = s.value as! [String : AnyObject]
                        
                        if (dictionary["timestamp"] as? Double == self.currentTimestamp) {
                            continue
                        }
                        
                        let anews = News()
                        
                        anews.timestamp = dictionary["timestamp"] as? Double
                        anews.title = dictionary["title"] as? String
                        anews.text = dictionary["text"] as? String
                        
                        self.news.insert(anews, at: index)
                        print(dictionary)
                    }
                    
                    self.currentKey = first.key
                    self.currentTimestamp = first.childSnapshot(forPath: "timestamp").value as! Double
                    
                    self.collectionView?.reloadData()
                }
                
            })
        }
    }
    
    
    // с автоматическим отслеживанием обновлений
    func getNewsON(){
        
        if self.currentKey == nil{
            
            Database.database().reference().child("news").queryOrdered(byChild: "timestamp").queryLimited(toLast: 5).observe(.value, with: { (snap:DataSnapshot) in
                
                if snap.childrenCount > 0 {
                    
                    let first = snap.children.allObjects.first as! DataSnapshot
                    
                    for s in snap.children.allObjects as! [DataSnapshot]{
                        let dictionary = s.value as! [String : AnyObject]
                        
                        let anews = News()
                        
                        anews.timestamp = dictionary["timestamp"] as? Double
                        anews.title = dictionary["title"] as? String
                        anews.text = dictionary["text"] as? String
                        
                        self.news.insert(anews, at: 0)
                        print(dictionary)
                    }
                    
                    self.currentKey = first.key
                    self.currentTimestamp = (first.value as! [String : AnyObject])["timestamp"] as! Double
                    print(self.currentTimestamp)
                    
                    self.collectionView?.reloadData()
                }
            })
        }
        else{
            
            Database.database().reference().child("news").queryOrdered(byChild: "timestamp").queryEnding(atValue: self.currentTimestamp).queryLimited(toLast: 6).observe(.value , with: { (snap:DataSnapshot) in
                
                
                let index = self.news.count
                
                if snap.childrenCount > 0 {
                    
                    let first = snap.children.allObjects.first as! DataSnapshot
                    
                    for s in snap.children.allObjects as! [DataSnapshot]{
                        let dictionary = s.value as! [String : AnyObject]
                        
                        if (dictionary["timestamp"] as? Double == self.currentTimestamp) {
                            continue
                        }
                        
                        let anews = News()
                        
                        anews.timestamp = dictionary["timestamp"] as? Double
                        anews.title = dictionary["title"] as? String
                        anews.text = dictionary["text"] as? String
                        
                        self.news.insert(anews, at: index)
                        print(dictionary)
                    }
                    
                    self.currentKey = first.key
                    self.currentTimestamp = first.childSnapshot(forPath: "timestamp").value as! Double
                    
                    self.collectionView?.reloadData()
                }
                
            })
        }
    }

}
