//
//  DetailNews.swift
//  Demo
//
//  Created by Stanislav Korolev on 06.01.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

class DetailNews: UIView {
    
    private var startFrame: CGRect?
    private var color: UIColor?
    
    
    let fullView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        
        // Тень
        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.7
        return view
    }()
    var headerImageView: UIView = {
        let imageView = UIView()
        return imageView
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.text = ""
        return label
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = ""
        
//        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 3.0
        
        label.sizeToFit()
        
        return label
    }()
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = ""
//
//        label.layer.borderWidth = 3.0
//        label.layer.borderColor = UIColor.black.cgColor

        return label
    }()
    
    
    var news: News? {
        didSet{
            titleLabel.text = news?.title
            textLabel.text = news?.text
            
            if let seconds = news?.timestamp {
                let date = Date(timeIntervalSince1970: seconds)
                
                let calendar = Calendar.current
                
                let day = calendar.component(.day, from: date)
                let hour = calendar.component(.hour, from: date)
                let minute = calendar.component(.minute, from: date)
                
                let cDate = Date()
                let cDay = calendar.component(.day, from: cDate)
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:MM"  //24 hours
                //                dateFormatter.dateFormat = "hh:mm a"  //12 hours am/pm
                
                let strTime: String = String(hour) + ":" + String(minute)
                var strDate: String = ""
                
                if cDay - day > 7 {
                    dateFormatter.dateFormat = "dd/MM/yy"
                    strDate = dateFormatter.string(from: date)
                } else if cDay - day > 1 {
                    dateFormatter.dateFormat = "EEEE"
                    strDate = dateFormatter.string(from: date)
                } else if cDay - day > 0 {
                    strDate = "ВЧЕРА"
                } else {
                    strDate = "СЕГОДНЯ"
                }
                
                
                dateLabel.text = strDate + ", " + strTime
                
            }
        }
    }
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        fullView.frame = frame
        
        self.color = color
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    func setNews(news: News){
        self.news = news
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // установка constrains
    func setupView(){
        
        addSubview(fullView)
        addSubview(fullView)
        fullView.addSubview(headerImageView)
        fullView.addSubview(textLabel)
        headerImageView.addSubview(dateLabel)
        headerImageView.addSubview(titleLabel)
        
        
        
        addConstraints(withFormat: "H:|[v0]|", views: fullView)
        addConstraints(withFormat: "V:|[v0]|", views: fullView)
        
        fullView.addConstraints(withFormat: "H:|[v0]|", views: headerImageView)
        fullView.addConstraints(withFormat: "H:|-20-[v0]-20-|", views: textLabel)
        fullView.addConstraints(withFormat: "V:|[v0(300)]-20-[v1]", views: headerImageView, textLabel)
        
        headerImageView.addConstraints(withFormat: "H:|-20-[v0]-20-|", views: titleLabel)
        headerImageView.addConstraints(withFormat: "H:|-20-[v0]", views: dateLabel)
        headerImageView.addConstraints(withFormat: "V:[v0]-20-[v1]-20-|", views: dateLabel, titleLabel)
        
        
        
        
    }
    
    func startAnimate(rectNews: CGRect){
        
        self.startFrame = rectNews
        
        // установка frame
        fullView.frame = CGRect(x: rectNews.minX, y: rectNews.minY, width: rectNews.width, height: rectNews.height)
        headerImageView = UIView(frame: CGRect(x: 0, y: 0, width: rectNews.width, height: rectNews.height))
        
        fullView.backgroundColor = .white
        headerImageView.backgroundColor = self.color
        
        setupView()
        
    }
    
    func endAnimate(rectNews: CGRect, rectFull: CGRect){
        
        let rectHeader = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: rectNews.height - 100)
        
        headerImageView.frame = rectHeader
        fullView.frame = rectFull
    }
    
    
    
    
    // MARK: - SWIPE GESTURE RECOGNIZE
    
    // SWIPE тоже можно
    func configureSwipeGestureRecognizer(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
        swipeDown.direction = .down
    
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(swipeDown)
    }

    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        print("123")
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
//            headerImageView.backgroundColor = .randomLightColor()
            print("down")
            
            
            self.endAnimate(rectNews: self.startFrame!, rectFull: self.fullView.frame)
            
            self.layoutIfNeeded()
            
            

            UIView.animate(withDuration: 0.5,
//                           delay: 0,
//                           usingSpringWithDamping: 1,
//                           initialSpringVelocity: 1,
//                           options: .curveEaseOut,
                           animations: {
                            // КОНЕЧНЫЙ frame
                            
//                            self.headerImageView.frame = self.startFrame!
//                            self.fullView.frame = self.startFrame!
                            self.frame = self.startFrame!
                            self.layoutIfNeeded()
                            },
                           completion: { (completeAnimation) in
                            // убрать status bar
                            UIApplication.shared.setStatusBarHidden(false, with: .fade)
                            self.removeFromSuperview()
            })
        }
    }
    
    
    // PAN лучше
    func configuratePanGestureRecognizer(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        
        
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.fullView)
        let yForClose: CGFloat = 100
        
        print(translation.y)
        if translation.y < 0 {
            return
        }
        
        if translation.y < yForClose{
            self.center = CGPoint(x: self.fullView.center.x, y: self.fullView.center.y + translation.y)
            self.fullView.center =  CGPoint(x: self.fullView.center.x, y: self.fullView.center.y + translation.y)

        }
        if gesture.state == .ended {
            
            if translation.y >= yForClose {
                self.frame = CGRect(x: 0, y: yForClose, width: self.frame.width, height: self.frame.height)
                self.fullView.frame = self.frame
                
              
                
                print("start \(self.frame)")
                print(self.fullView.frame)
                print(self.headerImageView.frame)
                print(UIScreen.main.bounds.width)
                
                self.layoutIfNeeded()
                
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                                // КОНЕЧНЫЙ frame
                                
                                print(self.frame)
                                print("end \(self.startFrame!)")
                                self.fullView.frame = self.startFrame!
                                self.frame = self.startFrame!
                                
                                self.fullView.layer.shadowOpacity = 0.1
                                
                                
                                self.dateLabel.textColor = UIColor.lightGray.withAlphaComponent(0)
                                self.textLabel.textColor = UIColor.black.withAlphaComponent(0)
                                self.titleLabel.textColor = UIColor.black.withAlphaComponent(0)
                                
                                self.layoutIfNeeded()
                                
                                },
                               completion: { (completeAnimation) in
                                
                                print(self.frame)
                                print(self.fullView.frame)
                                // убрать status bar
                                UIApplication.shared.setStatusBarHidden(false, with: .fade)
                                self.removeFromSuperview()
                })
            } else {
                // вернуться в прежнюю позицию
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin = CGPoint.zero
                })
            }
        }
    }
    
}

class DetailNewsLauncher: NSObject {
    
    func showDetailNews(news: News, rectNews: CGRect, color headerColor: UIColor){
        print("Showing detail news")
//        print(news)
        
        // Получаю keyWindow окна, из которого вызываю и отображаю UIView
        if let keyWindow = UIApplication.shared.keyWindow {
            
            // проициализировали стартовый frame для анимации
            let detailNews = DetailNews(frame: keyWindow.frame, color: headerColor)
            
            // НАЧАЛЬНЫЙ frame
            detailNews.startAnimate(rectNews: rectNews)
            
//            detailNews.fullView.layer.borderColor = UIColor.red.cgColor
//            detailNews.fullView.layer.borderWidth = 5.0
//            detailNews.layer.borderColor = UIColor.green.cgColor
//            detailNews.layer.borderWidth = 5.0
//            detailNews.headerImageView.layer.borderColor = UIColor.black.cgColor
//            detailNews.headerImageView.layer.borderWidth = 5.0
            
            keyWindow.addSubview(detailNews)
        
            
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                            // КОНЕЧНЫЙ frame
                            detailNews.endAnimate(rectNews: rectNews, rectFull: keyWindow.frame)
                            
                            },
                           completion: { (completeAnimation) in
                            // убрать status bar
                       
                            
                            // инициализация
                            detailNews.setNews(news: news)
                            // добавление дейсвтия для закрытия
                            // swipe
//                            detailNews.configureSwipeGestureRecognizer()
                            // pan
                            detailNews.configuratePanGestureRecognizer()
                            
                            UIApplication.shared.setStatusBarHidden(true, with: .fade)

            })
            
        }
    }
    
}
