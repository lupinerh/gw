//
//  SearchTeachersController.swift
//  project
//
//  Created by Stanislav Korolev on 20.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SearchTeachersController: UITableViewController {
    
    var currentKey: String!
    var teachers = [String]()
    var filteredTeachers = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(SearchTeacherCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Фамилия преподавателя"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        
        getTeachers()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredTeachers.count != 0 {
            return filteredTeachers.count
        }
        
        return teachers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! SearchTeacherCell
        let text: String?
        
        if filteredTeachers.count != 0 {
            text = filteredTeachers[indexPath.row]
        } else {
            text = teachers[indexPath.row]
        }
        
        cell.titleLabel.text = text
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let scheduleController = ScheduleController(collectionViewLayout: layout)
        let fio: String?
        
        
        if filteredTeachers.count != 0 {
             fio = filteredTeachers[indexPath.row]
        } else {
            fio = teachers[indexPath.row]
        }
        
        scheduleController.navigationItem.title = fio
      
        navigationController?.pushViewController(scheduleController, animated: true)
        
    }
    
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        let text = String(self.searchController.searchBar.text!.filter { !" \n\t\r".contains($0) })
        
        return text.count == 0 ? true : false
    }
    
}

extension SearchTeachersController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !searchBarIsEmpty() {
            // Достаем преподвателя с введенной фамилией
//            searchBar.text = "Колотий"
            self.getFilterTeacher(withSurname: searchBar.text!)
        } else {
            searchBar.text = ""
        
        }
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.filteredTeachers.removeAll()
        
        self.tableView.reloadData()
    }
    
}


class SearchTeacherCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addConstraints(withFormat: "H:|[v0]|", views: titleLabel)
        addConstraints(withFormat: "V:|[v0]|", views: titleLabel)
        
        
    }
}


