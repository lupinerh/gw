//
//  SearchTearchersTransfer.swift
//  project
//
//  Created by Stanislav Korolev on 20.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import Firebase

extension SearchTeachersController {
    
    // с автоматическим отслеживанием обновлений
    func getTeachers(){
        
        if self.currentKey == nil{
            
            Database.database().reference().child("users").queryOrdered(byChild: "role").queryEqual(toValue: "teacher").queryLimited(toLast: 15).observe(.value, with: { (snap:DataSnapshot) in
                
                if snap.childrenCount > 0 {
                    
                    let first = snap.children.allObjects.last as! DataSnapshot
                    self.currentKey = first.key
                    
                    for s in snap.children.allObjects as! [DataSnapshot]{
                        
                        print(s)
                        let dictionary = s.value as! [String : AnyObject]
                        
                        self.teachers.insert(dictionary["name"] as! String, at: 0)
                    }
                    
                   

                    print(self.teachers)
                    print(self.currentKey)
                    self.tableView?.reloadData()
                }
            })
        }
        else{
            
//        Database.database().reference().child("users").queryOrderedByKey().queryStarting(atValue: self.currentKey).queryLimited(toLast: 15).queryOrdered(byChild: "role").queryEqual(toValue: "teacher").observe(.value , with: { (snap:DataSnapshot) in
//
//                        if snap.childrenCount > 0 {
//
//                            let first = snap.children.allObjects.last as! DataSnapshot
//                            self.currentKey = first.key
//
//                            for s in snap.children.allObjects as! [DataSnapshot]{
//
//                                print(s)
//                                let dictionary = s.value as! [String : AnyObject]
//
//                                self.teachers.insert(dictionary["name"] as! String, at: 0)
//                            }
//
//
//
//                            print(self.teachers)
//                            print(self.currentKey)
//                            self.tableView?.reloadData()
//                        }
//                    })
        }
    }
    
    
   func getFilterTeacher(withSurname surname: String){
    Database.database().reference().child("users").queryOrdered(byChild: "surname").queryEqual(toValue: surname).observe(.value, with: { (snap:DataSnapshot) in
        
        if snap.childrenCount > 0 {
            

            for s in snap.children.allObjects as! [DataSnapshot]{
                
            
                let dictionary = s.value as! [String : AnyObject]
                
                self.filteredTeachers.insert(dictionary["name"] as! String, at: 0)
            }
            
        
            self.tableView?.reloadData()
        }
    })
    }
}
