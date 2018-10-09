//
//  JournalThemeTransfer.swift
//  project
//
//  Created by Stanislav Korolev on 11.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import Firebase

extension JournalDetailLessonController {
    func observeThemes(){
    
            print("начало")
            let key = String(self.numberLesson!) + self.group!
            
        
            self.needRemove = true
            var counter = 0
        
            let ref = Database.database().reference().child("themes").child(self.fio!).child(key).queryOrderedByKey()
            ref.observe(.value) { (snapshot) in
                print(snapshot.childrenCount)
                
                if (self.needRemove) {
                    self.lessonTitleThemes.removeAll()
                    self.lessonThemes.removeAll()
                    
                    self.needRemove = false
                    counter = 0
                }
                
                let themesEnumerator = snapshot.children
                while let themes = themesEnumerator.nextObject() as? DataSnapshot {
                  
                    if let themesDict = themes.value as? [String : AnyObject] {
                        
                        self.lessonThemes[themes.key] = (themesDict)
                        
                        self.lessonTitleThemes.append(themesDict["theme"] as! String)
                        self.lessonKeys[counter] = themes.key as! String
                        counter += 1

                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            
                        })
                    }
                    
                }
                
                if (self.lessonThemes.count == snapshot.childrenCount) {
                    
                    self.needRemove = true
                }
                
        }
    }
    
    
    func removeTheme(forKey key: String){
        let numberLessonAndGroup = String(self.numberLesson!) + String(self.group!)
        
        let ref =  Database.database().reference().child("themes").child(self.fio!).child(numberLessonAndGroup).child(key)
        ref.removeValue { error, _ in

            print(error)
        }
     
    }
        
        
    
}
