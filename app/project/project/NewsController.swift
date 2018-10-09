//
//  ViewController.swift
//  Demo
//
//  Created by Stanislav Korolev on 04.01.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

class NewsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var refresher: UIRefreshControl!
    static var currentOffsetY: CGFloat = 0.0
    
    let cellId = "cellId"
    
    var news = [News]()
    
    
    var currentKey:String!
    var currentTimestamp:Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        // Регистрирование ячейки коллекции
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(NewsCardCell.self, forCellWithReuseIdentifier: "cellId")
    
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        
//        createData()
        
//        let start = DispatchTime.now()
//        let end = DispatchTime.now();
//
//        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
//        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
//
//        print("Time to evaluate problem \(timeInterval) seconds")
        
        
        refresher = UIRefreshControl()
//        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshNews), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refresher)
        
        
//        getNewsONCE()
        getNewsON()

    }
    

    // Размер секции
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Колличество ячеек в одной секции
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    // Добавление ячеек
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! NewsCardCell
        
        if (self.news.count > 0) {
            let news = self.news[indexPath.row]
            cell.news = news
        }
        
        return cell
    }
    
    

    
    // Размер NewsCard
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: NewsCardCell.cellHeight)
    }
    
    
    
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView
//    }
    
    
    
    // SCROLL
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        NewsController.currentOffsetY = currentOffset
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
//        print(self.news.count)
        if maxOffset - currentOffset <= 400{
            getNewsONCE()
        }
    }
    
    @objc func refreshNews(){
        self.news.removeAll()
//        print(self.news)
        
        self.currentKey = nil
        self.currentTimestamp = nil
        
//        getNewsONCE()
        getNewsON()
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
            
        })
        
    }
    
    internal func getRootView() -> UIView {
        let view = self.view
        
        return view!
    }
  

    
}


class NewsCardCell: UICollectionViewCell {
    
    /// Высота ячейки
    internal static let cellHeight: CGFloat = 400
    
    /// Is Pressed State
    private var isPressed: Bool = false
    
    // вставка УЖЕ подгруженных данных в поля
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
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureGestureRecognizer()
    }
    
    
    
    let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .randomLightColor()
        imageView.layer.cornerRadius = 16
        
        // Тень
        imageView.layer.shadowRadius = 10.0
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowOpacity = 0.45
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0.95
        
        // округление только верхней части
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-50, height: 101)
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners:[.topLeft, .topRight],
                                cornerRadii: CGSize(width: 15, height:  15))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        label.text = "СЕГОДНЯ"
        return label
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = "Заголовок"
        return label
    }()
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = "Текст"
        label.textAlignment = .center
//        label.sizeToFit()
//        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 3.0
        return label
    }()
    
    
    
    
    func setupViews(){
        

        addSubview(previewImageView)
        previewImageView.addSubview(overlayView)
        previewImageView.addSubview(textLabel)
        overlayView.addSubview(dateLabel)
        overlayView.addSubview(titleLabel)
        
        addConstraints(withFormat: "H:|-25-[v0]-25-|", views: previewImageView)
        addConstraints(withFormat: "V:|-20-[v0]-20-|", views: previewImageView)

        previewImageView.addConstraints(withFormat: "H:|[v0]|", views: overlayView)
        previewImageView.addConstraints(withFormat: "V:|-(-1)-[v0(101)]-20-[v1]-20-|", views: overlayView,textLabel)
                
        previewImageView.addConstraints(withFormat: "H:|-20-[v0]-20-|", views: textLabel)

        overlayView.addConstraints(withFormat: "H:|-20-[v0]-20-|", views: dateLabel)
        overlayView.addConstraints(withFormat: "H:|-20-[v0]-20-|", views: titleLabel)
        
        overlayView.addConstraints(withFormat: "V:|-15-[v0][v1]-15-|", views: dateLabel, titleLabel)

        
    }
    
    
    
    
    
    // MARK: - Gesture Recognizer
    
    func configureGestureRecognizer() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleCardGesture(_:)))
//        // минимальное нажатие
        tapGesture.minimumPressDuration = 0.2
        
        previewImageView.isUserInteractionEnabled = true
        previewImageView.addGestureRecognizer(tapGesture)
    }

    @objc func handleCardGesture(_ gestureRecognizer: UILongPressGestureRecognizer){
//        print(gestureRecognizer.state)
        
        // Получаем нажатое view относительно корненого view, а не ячеек (cell)
        let rectInRootView = self.convert(previewImageView.frame, to: self.superview)
//        print("tap \(rectInRootView)")
        
        let rectInScreen = CGRect(x: rectInRootView.minX, y: rectInRootView.minY - NewsController.currentOffsetY, width: rectInRootView.width, height: rectInRootView.height)

        
//        print(rectInScreen)
        
        
        if gestureRecognizer.state == .began {
            handleCardBegan(fromRectAnimate: rectInScreen)
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    private func handleCardBegan(fromRectAnimate: CGRect){
        print("tap began")
        
        guard !isPressed else {
            return
        }
        
        isPressed = true
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                    self.previewImageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    },
                       completion: { (value: Bool) in
                        
                        // отображение детально новости
                        let detailNewsLauncher = DetailNewsLauncher()
                        detailNewsLauncher.showDetailNews(news: self.news!, rectNews: fromRectAnimate, color: self.previewImageView.backgroundColor!)
        })
    }
    
    private func handleLongPressEnded() {
        print("tap end")
        guard isPressed else {
            return
        }
        
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                         self.previewImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finished) in
            self.isPressed = false
        }
    }
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(codes:) has not been implement")
    }
}










