//
//  JournalGroupsTransfer.swift
//  project
//
//  Created by Stanislav Korolev on 07.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import Firebase

extension JournalLessonsController {
   
    
    func observeLessonsGroups(){
        //        if let uid = self.currentUser?.id {
        if let name = self.currentUser?.name {
            let nameSplit = name.split(separator: " ")
            let fio = nameSplit[0] + nameSplit[1].prefix(1) + nameSplit[2].prefix(1)
            self.fio = String(fio)
            Database.database().reference(withPath: "journals").child(String(fio)).observe(.childAdded) { (snapshot) in
                
               
    
                var arrayGroups = [String]()

                let lessonsEnumerator = snapshot.children
                while let lessons = lessonsEnumerator.nextObject() as? DataSnapshot {
                    let lessonsDict = lessons.value as! [String : AnyObject]
                    let allGroups = lessonsDict["groups"] as! NSArray
                    
                    allGroups.forEach({ (agroup) in
                        arrayGroups.append(agroup as! String)
                    })
        

                    

                    self.lessonsInJournal.append(lessonsDict["title"] as! String)
                    self.lessonsGroups[lessonsDict["title"] as! String] = arrayGroups
                }
                
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    
                })
                
            }
        }
    }
}
