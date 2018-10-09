//
//  SignUpController.swift
//  project
//
//  Created by Stanislav Korolev on 28.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import Firebase


class SignUpController: UIViewController {
    
    
    lazy var roleSegmentedControl: UISegmentedControl = {
        let items = ["Преподаватель","Студент"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1
        sc.tintColor = .white
        sc.translatesAutoresizingMaskIntoConstraints = false
        
        sc.addTarget(self, action: #selector(handleRoleSelectedControl), for: .valueChanged)
        return sc
    }()
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    let backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Назад", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        return button
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: String)
        imageView.backgroundColor = UIColor.randomLightColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Имя"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Пароль"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()
    let groupTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Группа"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let departmentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Кафедра"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let groupDepartmentSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let groupSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var groupTextFieldHeightAnchor: NSLayoutConstraint?
    var departmentTextFieldHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        setupView()
        setupTarget()
    }
    
    //скрыть клавиатуру
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupView(){
        // x, y, widht, height
        view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 200)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        // segmented control
        view.addSubview(roleSegmentedControl)
        roleSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        roleSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        roleSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        roleSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // button
        view.addSubview(signUpButton)
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signUpButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        signUpButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // profileImageView
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: roleSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        // x, y, widht, height
        inputContainerView.addSubview(groupTextField)
        inputContainerView.addSubview(departmentTextField)
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(passwordTextField)
        inputContainerView.addSubview(groupSeparatorView)
        inputContainerView.addSubview(groupDepartmentSeparatorView)
        inputContainerView.addSubview(emailSeparatorView)
        
        
        // group
        groupTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        groupTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        groupTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 1/2).isActive = true
        groupTextFieldHeightAnchor = groupTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4)
        groupTextFieldHeightAnchor?.isActive = true
        
        
        // department
        departmentTextField.leftAnchor.constraint(equalTo: groupTextField.rightAnchor, constant: 12).isActive = true
        departmentTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        departmentTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 1/2).isActive = true
        departmentTextFieldHeightAnchor = departmentTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4)
        departmentTextFieldHeightAnchor?.isActive = true
        
        // name
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: groupTextField.bottomAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        // x, y, widht, height
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // email
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        // password
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // separator
        // group
        groupSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        groupSeparatorView.topAnchor.constraint(equalTo: groupTextField.bottomAnchor).isActive = true
        groupSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        groupSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // groupDarpment
//        groupDepartmentSeparatorView.leftAnchor.constraint(equalTo: groupTextField.rightAnchor).isActive = true
//        groupDepartmentSeparatorView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
//        groupDepartmentSeparatorView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/4).isActive = true
//        groupDepartmentSeparatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        // email
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        // button
        view.addSubview(backButton)
        backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addConstraints(withFormat: "V:[v0]-10-|", views: backButton)
        
    }
    
    func setupTarget(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        
        signUpButton.addTarget(self, action: #selector(handleSignUp(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
    }
    
    
    
    // выбор role
    @objc func handleRoleSelectedControl(){
        print(roleSegmentedControl.selectedSegmentIndex)
        
        inputsContainerViewHeightAnchor?.constant = roleSegmentedControl.selectedSegmentIndex == 0 ? 150 : 200
        
        groupTextFieldHeightAnchor?.isActive = false
        groupTextFieldHeightAnchor = groupTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: roleSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/4)
        groupTextFieldHeightAnchor?.isActive = true
        
        departmentTextFieldHeightAnchor?.isActive = false
        departmentTextFieldHeightAnchor = departmentTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: roleSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/4)
        departmentTextFieldHeightAnchor?.isActive = true
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: roleSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: roleSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: roleSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    // выбор назад
    @objc func handleBack(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    

    // выбор загеристрироваться
    @objc func handleSignUp(_ sender: UIButton){
        guard let email = emailTextField.text.nilIfEmpty, let password = passwordTextField.text.nilIfEmpty, let name = nameTextField.text.nilIfEmpty, var group = groupTextField.text, var department = departmentTextField.text else {
            print("форма пустая или неверная")
            return
        }
        
        let role = roleSegmentedControl.selectedSegmentIndex == 0 ? "teacher" : "student"
        
        //регистрация в firebase/auth
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            
            guard let uid = user?.uid else {
                return
            }
            
            
            // загрузка профильного изображения в storage
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            // проверяем, выбрал ли пользователь фотографию
            if self.profileImageView.image == nil {
//                self.profileImageView.image = UIImage(named: "profileImageView_standard")
//                self.profileImageView.image = UIImage()
//                self.profileImageView.backgroundColor = UIColor.randomLightColor()
            }
            // конвертируем изображение png в nsdata
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                //загрузка
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        var values = [String: AnyObject]()
                        if (self.roleSegmentedControl.selectedSegmentIndex == 0) {
                            let surname = name.split(separator: " ")[0]
                            values = ["role": role, "name": name, "surname": surname, "email": email, "profileImageUrl": profileImageUrl] as [String : AnyObject]
                        } else {
                            group = String(group.filter { !" \n\t\r".contains($0) })
                            department = String(department.filter { !" \n\t\r".contains($0) })
                            let firstCharGroup = group[0] as Character
                            department.insert(firstCharGroup, at: department.startIndex)
                            
                            values = ["role": role, "group": group, "department": department, "name": name, "email": email, "profileImageUrl": profileImageUrl] as [String : AnyObject]
                        }
// signUp user
                        self.signUpUserIntoDatabase(withUID: uid, values: values)
                        
                        
                    }
                    
                    print(metadata)
                    
                })
            }
            
        })
    }
    
    private func signUpUserIntoDatabase(withUID uid: String, values: [String:AnyObject]){
        
        //подключение в database зарегистрированного пользователя
        // сохранение его данных
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
    
        usersReference.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error)
                return
            }
            
            print("Пользователь сохранился в firebase database ")
            
            
            // убираем 2 контроллера, переход на custom tab bar

            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
