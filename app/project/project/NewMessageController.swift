//
//  NewMessageController.swift
//  project
//
//  Created by Stanislav Korolev on 02.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase

private let cellId = "cellId"

class NewMessageController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var friends = [User]()
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = .white
        self.collectionView!.register(FriendCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        tabBarController?.tabBar.isHidden = true
        
        
        //fetchUserRealm()
        fetchUserFirebase()
        
    }
    
    
    func fetchUserFirebase(){
        
        // достаем данные всех друзей
        // данные выдаются по одному последовательно
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                //преобрзование словаря в объект
                
                user.id = snapshot.key // присваиваю id == uid
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.role = dictionary["role"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                
                
                self.friends.append(user)
                print(self.friends[0].email)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }
            
        }, withCancel: nil)
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //firebase
        return friends.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCell
        
        // firebase
        cell.friend = friends[indexPath.row]
        
        // realm
        //cell.friendRealm = friendsRealm[indexPath.row]
        
        return cell
    }
    
    
    
    //размер ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    // навигация, переход на ChatLogController
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatController(collectionViewLayout: layout)
        controller.friendFirebase = friends[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
}


class FriendCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet{
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white :  UIColor.black
        }
    }
    
    var friend: User? {
        didSet{
            nameLabel.text = friend?.name
            
            //необходимо скачать изображение
            if let profileImageUrl = friend?.profileImageUrl {
                let url = NSURL(string: profileImageUrl)
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
                    }
                    
                }).resume()
            }
        }
    }
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20           // округление картинки
        imageView.layer.masksToBounds = true        //подслои слоя, чтобы не выходили за пределы
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Elon Musk"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.white
        
        //добавляем на отображение
        addSubview(profileImageView)
        //addSubview(dividerLineView)
        
        addConstraints(withFormat:"H:|-12-[v0(40)]", views: profileImageView)
        addConstraints(withFormat:"V:[v0(40)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraints(withFormat: "H:|-90-[v0]|", views: containerView)
        addConstraints(withFormat: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        
        containerView.addSubview(nameLabel)
        
        
        containerView.addConstraints(withFormat: "H:|[v0]|", views: nameLabel)
        containerView.addConstraints(withFormat: "V:|[v0]|", views: nameLabel)
        
        //  addConstraintsWithFormat(format:"H:|-60-[v0]|", views: dividerLineView)
        //  addConstraintsWithFormat(format:"V:[v0(1)]|", views: dividerLineView)
        
    }
    
}


