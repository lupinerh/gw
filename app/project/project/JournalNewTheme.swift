//
//  JournalNewTheme.swift
//  project
//
//  Created by Stanislav Korolev on 10.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase

class JournalNewTheme: UIViewController {
    
    var numberLesson: Int?
    var group: String?
    var fio: String?
    
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        return button
    }()
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    let themeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Тема"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let homeworkTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Домашнее задание"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    let themeSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let createThemeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.lightGray , for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        
        setupView()
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        createThemeButton.addTarget(self, action: #selector(handleCreateTheme), for: .touchUpInside)
        
        
       
        
        
    }

    //скрыть клавиатуру
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func setupView(){
        // x, y, widht, height
        view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        
        // button
        view.addSubview(cancelButton)
        view.addConstraints(withFormat: "H:[v0]-20-|", views: cancelButton)
        view.addConstraints(withFormat: "V:|-30-[v0]", views: cancelButton)
        
        
        // button
        view.addSubview(createThemeButton)
        createThemeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createThemeButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        createThemeButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        createThemeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // x, y, widht, height
        inputContainerView.addSubview(themeTextField)
        inputContainerView.addSubview(themeSeparatorView)
        inputContainerView.addSubview(homeworkTextField)
        
        
        // theme
        themeTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        themeTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        themeTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        themeTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        
        // x, y, widht, height
        themeSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        themeSeparatorView.topAnchor.constraint(equalTo: themeTextField.bottomAnchor).isActive = true
        themeSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        themeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // homework
        homeworkTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        homeworkTextField.topAnchor.constraint(equalTo: themeTextField.bottomAnchor).isActive = true
        homeworkTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        homeworkTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 2/3).isActive = true
   
        
    
    
    }
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCreateTheme(){
        let key = String(self.numberLesson!) + self.group!
        let newTheme = themeTextField.text
        let newHomework = homeworkTextField.text
        
        
        
        guard (((newTheme?.filter { !" \n\t\r".contains($0) }) != "") && ((newHomework?.filter { !" \n\t\r".contains($0) }) != "")) else {
            print("Форма не введена")
            return
        }
        
        
        
        print(key)
        let ref = Database.database().reference().child("themes").child(self.fio!).child(key).childByAutoId()
        ref.setValue([
                        "theme": "\(newTheme!)",
                        "homework": "\(newHomework!)"
            
            ])
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
