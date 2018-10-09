//
//  JournalGroupsController.swift
//  project
//
//  Created by Stanislav Korolev on 07.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class JournalLessonsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var currentUser: User?
    var fio: String?
    var lessonsInJournal = [String]()
    var lessons = [String]()
    
    var lessonsGroups = [String : [String]]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .white
        
        observeLessonsGroups()


        // Register cell classes
        self.collectionView!.register(LessonCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    // MARK: UICollectionViewDataSource

    // количество ячеек
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonsInJournal.count
        
        
    }



    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LessonCell
    
        // Configure the cell
        cell.titleLabel.text = lessonsInJournal[indexPath.row]
    
        return cell
    }
    
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let journalGroupsController = JournalGroupsController(collectionViewLayout: layout)
        let selectedLesson = self.lessonsInJournal[indexPath.row]
        journalGroupsController.lesson = selectedLesson
        journalGroupsController.groups = self.lessonsGroups[selectedLesson]!
        journalGroupsController.currentUser = self.currentUser
        journalGroupsController.fio = self.fio
        
        
        journalGroupsController.numberLesson = Array(self.lessonsGroups.keys).index(of: self.lessonsInJournal[indexPath.row])
        
        
        self.navigationController?.pushViewController(journalGroupsController, animated: true)
    }

}


class LessonCell: BaseCell {
    
    
    
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
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addConstraints(withFormat: "H:|[v0]|", views: titleLabel)
        addConstraints(withFormat: "V:|[v0]|", views: titleLabel)
    }
    
}
