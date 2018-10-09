//
//  SignOutController.swift
//  project
//
//  Created by Stanislav Korolev on 01.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase

class SettingsController: UIViewController {
    
    var currentUser : User?

    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 0
        view.layer.masksToBounds = false

        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        
        return view
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: String)
        imageView.backgroundColor = UIColor.randomLightColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        
//        label.layer.borderWidth = 3.0
        return label
    }()
    let toJournalButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("Журнал", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        
        
        return button
    }()
    let signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("Выход", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        
        return button
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        self.navigationController?.isNavigationBarHidden = true

        
        self.getDatabaseCurrentUser{ success in
            if success {
                
                let url = NSURL(string: (self.currentUser?.profileImageUrl!)!)
                let request = URLRequest(url: url! as URL)
                //получение данных по url
                URLSession.shared.dataTask(with: request, completionHandler: { (data, responce, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    // поместить в главную очередь(?) загрузить ассинхронного
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data!)
                        self.nameLabel.text = self.currentUser?.name
                    }
                    
                }).resume()
                
            }
        }
        
        setupView()
        toJournalButton.addTarget(self, action: #selector(handleToJournal(_:)), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(handleSignOut(_:)), for: .touchUpInside)
    }
    
    
    func setupView(){
        
        //
        view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // profile image
        // name label
        

        inputContainerView.addSubview(profileImageView)
        inputContainerView.addSubview(nameLabel)
        
        profileImageView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        inputContainerView.addConstraints(withFormat: "V:|-20-[v0(100)][v1]-10-|", views: profileImageView, nameLabel)
        inputContainerView.addConstraints(withFormat: "H:|-12-[v0]-12-|", views: nameLabel)
        
        

        // button
        view.addSubview(toJournalButton)
        toJournalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toJournalButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        toJournalButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        toJournalButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(signOutButton)
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: toJournalButton.bottomAnchor, constant: 12).isActive = true
        signOutButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    
    // MARK:  ДЕЙСТВИЯ
    
    @objc func handleToJournal(_ sender: UIButton){
        let layout = UICollectionViewFlowLayout()
        let journalLessonsController = JournalLessonsController(collectionViewLayout: layout)
        journalLessonsController.currentUser = self.currentUser
        
        self.navigationController?.pushViewController(journalLessonsController, animated: true)
    }
    
    @objc func handleSignOut(_ sender: UIButton){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.present(SignInController(), animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

    
    
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
