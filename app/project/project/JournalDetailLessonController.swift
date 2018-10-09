//
//  JournalDetailLessonController2.swift
//  project
//
//  Created by Stanislav Korolev on 13.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import UIKit

private let reuseIdentifier = "Cell"

class JournalDetailLessonController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    var lessonThemes = [String : Dictionary<String, Any>]()
    var lessonTitleThemes = [String]()
    var lessonKeys = [Int : String]()
    var numberLesson: Int?
    var group: String?
    var fio: String?
    var currentKey: String?
    var needRemove = true
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.randomLightColor()
        
        view.layer.masksToBounds = true
        
        //        view.layer.borderColor = UIColor.green.cgColor
        //        view.layer.borderWidth = 5.0
        return view
    }()
    let titleLessonLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        
        //        label.layer.borderWidth = 3.0
        //        label.layer.borderColor = UIColor.red.cgColor
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleNewTheme))
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.backgroundColor = .white
        
        
        observeThemes()
        
        setupViews()
        
        // Register cell classes
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(LessonThemeCell1.self, forCellReuseIdentifier: reuseIdentifier)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupViews(){
        
        // add the table view to self.view
        self.view.addSubview(tableView)
    
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        view.addSubview(inputContainerView)
        
        view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0) .isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        inputContainerView.addSubview(titleLessonLabel)
        
        inputContainerView.addConstraints(withFormat: "H:|[v0]|", views: titleLessonLabel)
        titleLessonLabel.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor, constant: (self.navigationController?.navigationBar.frame.height)!).isActive = true
        
        
        
        
        
    }

    @objc func handleNewTheme(){
        let journalNewTheme = JournalNewTheme()
        journalNewTheme.numberLesson = self.numberLesson
        journalNewTheme.group = self.group
        journalNewTheme.fio = self.fio
        
        self.present(journalNewTheme, animated: true, completion: nil)
    }



    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonTitleThemes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! LessonThemeCell1
        
        cell.titleLabel.text = self.lessonTitleThemes[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    // edit
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let key = self.lessonKeys[indexPath.row] as! String
            self.lessonThemes.removeValue(forKey: key)
            self.lessonTitleThemes.remove(at: indexPath.row)
            
            

            removeTheme(forKey: key)
//
            self.tableView.reloadData()
          
        }
    }
    
    
    



}



class LessonThemeCell1: UITableViewCell {
    
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

