//
//  ScheduleTransfer.swift
//  project
//
//  Created by Stanislav Korolev on 02.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import Firebase

extension ScheduleController {
    
    func getDatabaseCurrentUser(completion: @escaping (Bool) -> ()){
        if Auth.auth().currentUser?.uid == nil {
            do {
                try Auth.auth().signOut()
                self.present(SignInController(), animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        } else {

            // достаем данные пользователя
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in


//                print(snapshot.value)

                //присваиваю словарь данных текущего авторизованного пользователя
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let currentUser = User()

                    currentUser.id = snapshot.key
                    currentUser.name = dictionary["name"] as? String
                    currentUser.email = dictionary["email"] as? String
                    currentUser.group = dictionary["group"] as? String
                    currentUser.department = dictionary["department"] as? String
                    currentUser.role = dictionary["role"] as? String
                    currentUser.profileImageUrl = dictionary["profileImageUrl"] as? String

                    self.currentUser = currentUser
                    completion(true)

                }



            })
        }
    }
    
    func observeSchedule(){
        
        if (self.currentUser?.role == "student"){
            // соединяем расписание группы и кафедры
            if self.currentUser?.department != nil {
                observeDepartment()
            }
            observeGroup()
        } else if (self.currentUser?.role == "teacher"){
            observeTeacher()
        }

    }
    
    func observeDepartment(){
        
        if let department = self.currentUser?.department {
            Database.database().reference(withPath: "schedule/groups").child(department).observe(.childAdded) { (snapshot) in
                
                
                
                var arrayLesson: [Lesson] = []
                var dict = [String : [Lesson]]()
                
                
                let lessonEnumerator = snapshot.children
                while let lesson = lessonEnumerator.nextObject() as? DataSnapshot {
                    let ndEnumerator = lesson.children
                    while let nd = ndEnumerator.nextObject() as? DataSnapshot{
                        if let ndDictionary = nd.value as? [String : AnyObject] {
                            let alesson = Lesson()
                            alesson.group = self.currentUser?.group
                            
                            if let dictNumberLesoon = lesson.value as? [String : AnyObject] {
                                alesson.date = dictNumberLesoon["timestamp"] as? String
                                //                                print(alesson.date)
                            }
                            
                            if self.ND == 0 {
                                alesson.name = ndDictionary["numerator"] as? String
                                //                                print(alesson.name)
                            } else {
                                alesson.name = ndDictionary["denominator"] as? String
                            }
                            
                            
                            
                            if let prevLessons = self.lessonOnWeek[snapshot.key] {
                                alesson.name! += (prevLessons[Int(lesson.key)! - 1].name)!
                            }
                            
                            arrayLesson.append(alesson)
                        }
                    }
                }
                
                
                print("++++++into transfer++++++++++")
                
                dict[snapshot.key] = arrayLesson
                self.lessonOnWeek[snapshot.key] = arrayLesson
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    
                })
            }
            
        }
    }
    
    func observeGroup(){
        if let group = self.currentUser?.group {
            Database.database().reference(withPath: "schedule/groups").child(group).observe(.childAdded) { (snapshot) in
                
                
                
                var arrayLesson: [Lesson] = []
                var dict = [String : [Lesson]]()
                
                
                let lessonEnumerator = snapshot.children
                while let lesson = lessonEnumerator.nextObject() as? DataSnapshot {
                    let ndEnumerator = lesson.children
                    while let nd = ndEnumerator.nextObject() as? DataSnapshot{
                        if let ndDictionary = nd.value as? [String : AnyObject] {
                            let alesson = Lesson()
                            alesson.group = self.currentUser?.group
                            
                            if let dictNumberLesoon = lesson.value as? [String : AnyObject] {
                                alesson.date = dictNumberLesoon["timestamp"] as? String
                                //                                print(alesson.date)
                            }
                            
                            if self.ND == 0 {
                                alesson.name = ndDictionary["numerator"] as? String
                                //                                print(alesson.name)
                            } else {
                                alesson.name = ndDictionary["denominator"] as? String
                            }
                            
                            if let prevLessons = self.lessonOnWeek[snapshot.key] {
                                alesson.name! += (prevLessons[Int(lesson.key)! - 1].name)!
                            }
                            
                            arrayLesson.append(alesson)
                            print(arrayLesson)
                        }
                    }
                }
                
                
                dict[snapshot.key] = arrayLesson
                self.lessonOnWeek[snapshot.key] = arrayLesson
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    
                })
            }
            
        }
    }
    
    
    func observeTeacher(){
//        if let teacherUID = self.currentUser?.id {
        if let name = self.currentUser?.name {
            let nameSplit = name.split(separator: " ")
            let fio = nameSplit[0] + nameSplit[1].prefix(1) + nameSplit[2].prefix(1)
            print("привет")
            Database.database().reference(withPath: "schedule/teachers").child(String(fio)).observe(.childAdded) { (snapshot) in



                var arrayLesson: [Lesson] = []
                var dict = [String : [Lesson]]()



                let lessonEnumerator = snapshot.children
//                print(lessonEnumerator)nd
                while let lesson = lessonEnumerator.nextObject() as? DataSnapshot {
//                    print(lesson.key)
                    let ndEnumerator = lesson.children
                    while let nd = ndEnumerator.nextObject() as? DataSnapshot{
                        if let ndDictionary = nd.value as? [String : AnyObject] {
                            let alesson = Lesson()
//                            alesson.group =

                            if let dictNumberLesoon = lesson.value as? [String : AnyObject] {
                                alesson.date = dictNumberLesoon["timestamp"] as? String
                                                                print(alesson.date)
                            }

//                            print(ndDictionary.keys)

                            if self.ND == 0 {
                                alesson.name = ndDictionary["numerator"]!["title"] as? String
                                alesson.group = ndDictionary["numerator"]!["group"] as? String
//                                print(alesson.name)
                            } else {
                                alesson.name = ndDictionary["denominator"]!["title"] as? String
                                alesson.group = ndDictionary["denominator"]!["group"] as? String
                            }


                            if let prevLessons = self.lessonOnWeek[snapshot.key] {
                                alesson.name! += (prevLessons[Int(lesson.key)! - 1].name)!
                            }

                            print(alesson)
                            arrayLesson.append(alesson)
                        }
                    }
                }


                dict[snapshot.key] = arrayLesson
                self.lessonOnWeek[snapshot.key] = arrayLesson

                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()

                })
            }
        }
    }
    
    
    
    func observeSchedule(withName name: String){
        
       
            let nameSplit = name.split(separator: " ")
            let fio = nameSplit[0] + nameSplit[1].prefix(1) + nameSplit[2].prefix(1)
           
            Database.database().reference(withPath: "schedule/teachers").child(String(fio)).observe(.childAdded) { (snapshot) in
                
                
                
                var arrayLesson: [Lesson] = []
                var dict = [String : [Lesson]]()
                
                
                
                let lessonEnumerator = snapshot.children
                //                print(lessonEnumerator)nd
                while let lesson = lessonEnumerator.nextObject() as? DataSnapshot {
                    //                    print(lesson.key)
                    let ndEnumerator = lesson.children
                    while let nd = ndEnumerator.nextObject() as? DataSnapshot{
                        if let ndDictionary = nd.value as? [String : AnyObject] {
                            let alesson = Lesson()
                            //                            alesson.group =
                            
                            if let dictNumberLesoon = lesson.value as? [String : AnyObject] {
                                alesson.date = dictNumberLesoon["timestamp"] as? String
                                print(alesson.date)
                            }
                            
                            //                            print(ndDictionary.keys)
                            
                            if self.ND == 0 {
                                alesson.name = ndDictionary["numerator"]!["title"] as? String
                                alesson.group = ndDictionary["numerator"]!["group"] as? String
                                //                                print(alesson.name)
                            } else {
                                alesson.name = ndDictionary["denominator"]!["title"] as? String
                                alesson.group = ndDictionary["denominator"]!["group"] as? String
                            }
                            
                            
                            if let prevLessons = self.lessonOnWeek[snapshot.key] {
                                alesson.name! += (prevLessons[Int(lesson.key)! - 1].name)!
                            }
                            
                            print(alesson)
                            arrayLesson.append(alesson)
                        }
                    }
                }
                
                
                dict[snapshot.key] = arrayLesson
                self.lessonOnWeek[snapshot.key] = arrayLesson
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    
                })
            }
        
    }
    
    
    
    func observeFake(){
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        createFakeLesson(withInterval: 0, name: "Алгебра", group: "31")
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            
        })
    }
    
    func createFakeLesson(withInterval: TimeInterval, name: String, group: String){
        let alesson = Lesson()
        alesson.date = String(describing: Date(timeIntervalSince1970: withInterval))
        alesson.group = group
        alesson.name = name
        
        
        lessons.append(alesson)
    }
}
