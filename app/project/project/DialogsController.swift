//
//  DialogsController.swift
//  project
//
//  Created by Stanislav Korolev on 01.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase


class DialogsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    //firebase
    // все сообщения от пользователя
    var messagesFirebase = [Message]()
    //  сохраняет последние сообщения от пользователя
    var messagesFirebaseDictionary = [String : Message]()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.isTranslucent = false
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleToNewMessage))
        Helper.setStatusBarBackgroundColor(color: UIColor.clear)
    
        
        //collectionView
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        
        //Регистрация класса для ячеек вручную
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        //загрузка сообщений firebase
        observeMessages()
    }
    
    
    // MARK: FIREBASE
    // получаем сообщения из firebase
    func observeMessages(){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("пользователь не найден")
            return
        }
        
        // запрос где ищем все сообщения отправленными текущему пользователю
        let ref = Database.database().reference().child("messeges").queryOrdered(byChild: "fromId").queryEqual(toValue: currentUserUID)
        ref.observe(.childAdded, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String : AnyObject] {
                let message = Message()

                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? Double
                message.toId = dictionary["toId"] as? String

                

                self.messagesFirebaseDictionary[message.toId!] = message
                self.messagesFirebase = Array(self.messagesFirebaseDictionary.values)

               

                print("СООБЩЕНИЯ")
                print(dictionary)
//                print(self.messagesFirebase)
//                print(self.messagesFirebaseDictionary.values)
                print("КОНЕЦ")

                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }

        }, withCancel: nil)
    }
    
    //количество ячеек
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesFirebase.count
    }
    
    
    // FIREBASE
    
    //возращает очеред ячеек
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //очередь ячеек с "id" - cellId и индексами
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let message = messagesFirebase[indexPath.row]
        print(messagesFirebase[indexPath.row])
        cell.message = message
        
        
        
        return cell
    }
    
    
    // рзамер ячеек?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    
    
   
    //FIREBASE
    // навигация, переход на ChatController
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatController(collectionViewLayout: layout)
        let toId = messagesFirebase[indexPath.row].toId
        Database.database().reference().child("users").child(toId!).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let currentUser = User()
                currentUser.id = snapshot.key // присваиваю id == uid
                currentUser.name = dictionary["name"] as? String
                currentUser.email = dictionary["email"] as? String
                currentUser.role = dictionary["role"] as? String
                currentUser.profileImageUrl = dictionary["profileImageUrl"] as? String

                controller.friendFirebase = currentUser
            }
        })
        navigationController?.pushViewController(controller, animated: true)

    }
    
    // переход на new message
    @objc func handleToNewMessage(){
        let layout = UICollectionViewFlowLayout()
        let newMessageController = NewMessageController(collectionViewLayout: layout)
        
        navigationController?.pushViewController(newMessageController, animated: true)
        
    }
    
}

// класс ячейки message
class MessageCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet{
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white :  UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white :  UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white :  UIColor.black
        }
    }
    
    //firebase
    var message: Message? {
        didSet{
            //
            //ставим текст
            self.messageLabel.text = message?.text
            
            //ставим время
            if let seconds = message?.timestamp {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                
                //работает уже с user
                if let toId = message?.toId {
                    let ref = Database.database().reference().child("users").child(toId)
                    ref.observe(.value, with: { (snapshot) in
                        
                        //print(snapshot)
                        
                        if let dictionary = snapshot.value as? [String : AnyObject] {
                            // ставим имя
                            self.nameLabel.text = dictionary["name"] as? String
                            //ставим/грузим изображение
                            if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                                
                                // надо расширыть UIImageView в дальнейшем
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
                    })
                }
            }
            
        }
    }
    

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30           // округление картинки
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
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10           // округление картинки
        imageView.layer.masksToBounds = true        //подслои слоя, чтобы не выходили за пределы
        return imageView
    }()
    
    
    override func setupViews(){
        super.setupViews();
        
        backgroundColor = UIColor.white
        
        
        //добавляем на отображение
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        
        setupContainerView()
        
        
        addConstraints(withFormat:"H:|-12-[v0(65)]", views: profileImageView)
        addConstraints(withFormat:"V:[v0(65)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraints(withFormat:"H:|-82-[v0]|", views: dividerLineView)
        addConstraints(withFormat:"V:[v0(1)]|", views: dividerLineView)
    }
    
    private func setupContainerView(){
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraints(withFormat: "H:|-90-[v0]|", views: containerView)
        addConstraints(withFormat: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        
        containerView.addConstraints(withFormat: "H:|[v0][v1(80)]-12-|", views: nameLabel,timeLabel)
        
        containerView.addConstraints(withFormat: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        containerView.addConstraints(withFormat: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        
        containerView.addConstraints(withFormat: "V:|[v0(24)]", views: timeLabel)
        
        containerView.addConstraints(withFormat: "V:[v0(20)]|", views: hasReadImageView)
    }
}


class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews(){
        
    }
}

