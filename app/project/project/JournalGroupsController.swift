//
//  JournalLessonsController.swift
//  project
//
//  Created by Stanislav Korolev on 10.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class JournalGroupsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var lesson: String?
    var groups = [String]()
    var currentUser: User?
    var fio: String?
    
    var numberLesson: Int?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.lesson
        self.collectionView?.backgroundColor = .white
        
//        print("~~~~~~~~~~~")
//        print(self.numberLesson)


        // Register cell classes
        self.collectionView!.register(GroupCell.self, forCellWithReuseIdentifier: reuseIdentifier)

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UICollectionViewDataSource

   

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return groups.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCell
    
        cell.titleLabel.text = groups[indexPath.row]
        
        
    
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let journalDetailLessonsController = JournalDetailLessonController()
        journalDetailLessonsController.titleLessonLabel.text = self.lesson! + " \n" + self.groups[indexPath.row]
        journalDetailLessonsController.numberLesson = self.numberLesson
        journalDetailLessonsController.group = self.groups[indexPath.row]
        journalDetailLessonsController.fio = self.fio


        self.navigationController?.pushViewController(journalDetailLessonsController, animated: true)
    }
    

}



class GroupCell: BaseCell {
    
    
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "привет"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        
        //        label.layer.borderWidth = 3.0
        return label
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.randomLightColor()
        
        
        
        addSubview(titleLabel)
        addConstraints(withFormat: "H:|[v0]|", views: titleLabel)
        addConstraints(withFormat: "V:|[v0]|", views: titleLabel)
    }
    
    
    
}
