//
//  ChatController.swift
//  project
//
//  Created by Stanislav Korolev on 02.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    private let cellId = "cellId"
    
    
    //Firebase
    var messages = [Message]()
    
    //Firebase friend
    var friendFirebase: User? {
        didSet{
            navigationItem.title = friendFirebase?.name
        }
    }
    
    
    
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите сообщение"
        textField.delegate = self
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отправить", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        // присваимаем событие
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(friendFirebase?.name)
        tabBarController?.tabBar.isHidden = true
        
        collectionView?.backgroundColor = UIColor.white
        
        
        self.collectionView!.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        //добавление нижней панели messageInputContainerView
        view.addSubview(messageInputContainerView)
        view.addConstraints(withFormat: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraints(withFormat: "V:[v0(40)]", views: messageInputContainerView)
        
        setupInputComponents()
        
        // добавление constrain такого, что при открытии textfield был снизу
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        
        // регистрируется для получения уведомлений / уведомляет handleKeyboardWillShow о показе клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        // о скрытии клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
        
        // загрузка сообщений из firebase
        observeMessages()
        
    }
    
    private func setupInputComponents(){
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraints(withFormat: "H:|-8-[v0][v1(100)]-6-|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraints(withFormat: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraints(withFormat: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraints(withFormat: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraints(withFormat: "V:|[v0(0.5)]", views: topBorderView)
        
    }
    
    
    
    
    // получает уведомление о показе клавиатуры
    @objc func handleKeyboardNotification(notification: Notification){
        
        if let userInfo = notification.userInfo {
            
            // прямоугольник экрана (x, y, width, height)
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            // проверяем какое уведомление пришло
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            // координаты по y / 0 считается от привязки constraint
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            // длительность, задержка, как будет происходить(изгиб кривой?),
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
                
            }, completion: { (completed) in
                
             
                
                // FIREBASE
                if isKeyboardShowing {
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(item: (self.messages.count) - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
                
            })
            
            
        }
        
    }
    
    
    //MARK: Firebase
    // получаем сообщения из firebase
    func observeMessages(){
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("пользователь не найден")
            return
        }
        
        messages.removeAll()
        
        let ref = Database.database().reference().child("messeges").queryOrdered(byChild: "toId").queryEqual(toValue: currentUserUID)
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let message = Message()
                
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? Double
                message.toId = dictionary["toId"] as? String
                
               if (message.fromId == self.friendFirebase?.id) {
                    // добавляем в массив
                    self.messages.append(message)
                    print(self.messages.count)
                }
                
                DispatchQueue.main.async  {
                    self.collectionView?.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleSend(){
        let ref = Database.database().reference().child("messeges")
        // автоматически id присваивается
        let childRef = ref.childByAutoId()
        // кому сообщение
        let toId = friendFirebase!.id!
        // от кого
        let fromId = Auth.auth().currentUser?.uid
        let timestamp: Int = (Int(NSDate().timeIntervalSince1970))
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values)
        print(friendFirebase?.name)
        self.observeMessages()
        
      
        
        inputTextField.text = nil
    }
    
    //что должно делать после нажатие return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // firebase
        return messages.count
    }
    
    // MARK: CellForItemAt indexPath FIREBASE
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        
        //Firebase
        cell.messageTextView.text = messages[indexPath.item].text
        
        //Firebase
        let message = messages[indexPath.item]
        let messageText = message.text
        
        
        //cell.profileImageView.image = UIImage(named: profileImageName)
        print(messageText)
        
        //вычисление размнров прямоугольиника под текст
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
        
        // приходит или уходит сообщение
        if message.fromId != Auth.auth().currentUser?.uid {
            cell.messageTextView.frame = CGRect(x: 44 + 6, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 15)
            cell.textBubbleView.frame = CGRect(x: 44, y: 0, width: estimatedFrame.width + 16 + 6, height: estimatedFrame.height + 15)
            cell.profileImageView.isHidden = false
            cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            cell.messageTextView.textColor = UIColor.black
            
        } else {
            // уходящие сообщения
            
            cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 12, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 15)
            cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 6 - 12, y: 0, width: estimatedFrame.width + 16 + 6, height: estimatedFrame.height + 15)
            cell.profileImageView.isHidden = true
            cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            cell.messageTextView.textColor = UIColor.white
            
        }
        
        
        
        
        return cell
    }
    
    
    
    
    // FIREBASE размер ячейки
    //размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //размер ячейки, подстраиваем height
        let messageText = messages[indexPath.item].text
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
        return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
    }
    
    //отступ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    
}


class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        addConstraints(withFormat: "H:|-8-[v0(30)]|", views: profileImageView)
        addConstraints(withFormat: "V:[v0(30)]|", views: profileImageView)
    }
    
}
