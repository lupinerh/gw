import UIKit
import Firebase

var lessons = [Lesson]()
var navigationControllerInClass: UINavigationController?

var userDictionary: [String: AnyObject]?

class ScheduleController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellIdHorizonatal = "cellIdHorizontal"
    
    let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentUser: User?
    var lessonOnWeek: [String : [Lesson]] = [:]
    var ND = 0
    
  
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
       self.navigationController?.navigationBar.isTranslucent = false
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationControllerInClass = navigationController
        self.view.backgroundColor = .white
        Helper.setStatusBarBackgroundColor(color: .white)
        
       
        
        
        
        
        // Register cell classes
        self.collectionView!.register(WeekCellHorizontal.self, forCellWithReuseIdentifier: cellIdHorizonatal)
        
        
        setupCollectionViewsLayoutWithContsraints()
        

        if navigationItem.title == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Поиск", style: .plain, target: self, action: #selector(handleSearchTeacher))
            
            //   загрузка текущего пользователя, а после него и расписания
            getDatabaseCurrentUser{ success in
                if success {
                    //                        self.observeFake()
                    self.observeSchedule()
                    
                }
            }
            
            
        } else {
            self.observeSchedule(withName: (navigationItem.title)!)
        }
        
      
        
    }
    
    private func setupCollectionViewsLayoutWithContsraints(){
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView?.isPagingEnabled = true
        
          
        
        //добавляем constraints
        // чтобы верхние и нижнии bar не заслонял
        self.edgesForExtendedLayout = .bottom
        self.extendedLayoutIncludesOpaqueBars = false
        
        view.addSubview(topSeparatorView)
        
       
        
        topSeparatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        topSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let colors: [UIColor] = [.blue, .green, .orange, .purple, .lightGray, .magenta, .yellow]
        let week: [String] = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdHorizonatal, for: indexPath) as! WeekCellHorizontal
        
        // добавление информации о дате
        let currentDateForIndexPath = Date().addingTimeInterval(TimeInterval(indexPath.item * (60 * 60 * 24)))
        let calendar = Calendar.current
        
//        let day = calendar.component(.day, from: currentDateForIndexPath)
        let dayToWeek = calendar.component(.weekday , from: currentDateForIndexPath)
        
        
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let strDate = dateFormatter.string(from: currentDateForIndexPath)
        
        
        cell.day = currentDateForIndexPath
        
        
        
        print("~~~~~~~~~~~~~~~~~~~~")
        print(dayToWeek)
        print(week[dayToWeek-1])
        
        let keysWeek = Array(self.lessonOnWeek.keys)

        
//            print(self.lessonOnWeek)
        if let lessons = self.lessonOnWeek[week[dayToWeek-1]] {

            cell.lessonsInDay = lessons
        } else {
            cell.lessonsInDay = []
        }
        
        
        self.lessonOnWeek.forEach { (day) in

            day.value.forEach({ (lesson) in
            })
        }
        
        return cell
    }
    
    
    
    //размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
    // MARK: handle
    
    @objc func handleSearchTeacher(){
        print("search")
         print(self.view.frame)
        
        let searchTeachersController = SearchTeachersController()
        self.navigationController?.pushViewController(searchTeachersController, animated: true)
    }
    
}


class WeekCellHorizontal : BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var lessonsInDay = [Lesson]() {
        didSet {
            DispatchQueue.main.async(execute: {
                self.collectionViewSchedule.reloadData()
            })
        }
    }
    
    var day: Date? {
        didSet{
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "EEE"
            let dayEEE = dateFormatter.string(from: day!)
            dayEEELabel.text = dayEEE
            
            dateFormatter.dateFormat = "d MMMM"
            let dayDDMM = dateFormatter.string(from: day!)
            dayDDMMLabel.text = dayDDMM
            
            DispatchQueue.main.async(execute: {
                self.collectionViewSchedule.reloadData()
            })
        }
    }
    
    var dayString: String? {
        didSet{
            dayEEELabel.text = dayString
        }
    }
    
    var dayEEELabel: UILabel = {
        let label = UILabel()
        label.text = "date EEE"
        label.font = UIFont.systemFont(ofSize: 67)
        label.textColor = .black
        return label
    }()
    
    let dayDDMMLabel: UILabel = {
        let label = UILabel()
        label.text = "date DDMM"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    let bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //добавиление вертикального collectionView
    lazy var collectionViewSchedule: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        
        let flowLayout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = 1
        
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let cellIdLesson = "cellIdLesson"
    
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        addSubview(dayEEELabel)
        addSubview(dayDDMMLabel)
        
        //добавляем constrains
        addConstraint(NSLayoutConstraint(item: dayEEELabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: dayDDMMLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraints(withFormat: "V:|-30-[v0(90)][v1]", views: dayEEELabel, dayDDMMLabel)
        
        addSubview(collectionViewSchedule)
        addSubview(bottomSeparatorView)
        
        addConstraints(withFormat: "H:|[v0]|", views: collectionViewSchedule)
        addConstraints(withFormat: "V:|-140-[v0]|", views: collectionViewSchedule)
        
        
        bottomSeparatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bottomSeparatorView.topAnchor.constraint(equalTo: collectionViewSchedule.topAnchor).isActive = true
        bottomSeparatorView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //регистрация класса ячейки расписания
        
        collectionViewSchedule.register(LessonCellVertical.self, forCellWithReuseIdentifier: cellIdLesson)
        
    }
    
    
    // data source вертикальных ячеек
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.lessonsInDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colors: [UIColor] = [.blue, .green, .orange, .purple, .lightGray, .magenta, .yellow, .white, .red, .lightGray, .white]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdLesson, for: indexPath) as! LessonCellVertical
       
        cell.lesson = self.lessonsInDay[indexPath.row]
        
        return cell
    }
    
    //размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 150)
    }
    
    
    //    //навигация в VisitController
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //
    //        if userDictionary != nil{
    //            //если роль преподаватель, то показывать список группы, если студент, но ничего не показывать
    //            if (userDictionary!["role"]! as! String == "преподаватель"){
    //
    //                let layout = UICollectionViewFlowLayout()
    //                let controller = VisitLessonController(collectionViewLayout: layout)
    //                navigationControllerInClass?.pushViewController(controller, animated: true)
    //            }
    //        }
    //    }
    //
    
}


class LessonCellVertical: BaseCell {
    
    
    var lesson: Lesson? {
        didSet{
            print("~~~~~~~~~~~~~")
            nameLabel.text = lesson?.name
            groupLabel.text = lesson?.group
            
            
            //            if let date = lesson?.date as Date? {
            //
            //                let dateFormatter = DateFormatter()
            //                //dateFormatter.dateFormat = "hh:mm"  //24 hours
            //                dateFormatter.dateFormat = "hh:mm a"  //12 hours am/pm
            //
            //
            //
            //
            //                timeLabel.text = dateFormatter.string(from: date)
            //            }
            timeLabel.text = lesson?.date
            
            
            
            
        }
    }
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Астрономия"
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    var groupLabel: UILabel = {
        let label = UILabel()
        label.text = "32 группа"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "date mm h"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(groupLabel)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(dividerLineView)
        
        
        addConstraints(withFormat: "H:|-10-[v0][v1]-10-|", views: groupLabel, timeLabel)
        addConstraints(withFormat: "H:|-10-[v0]-10-|", views: nameLabel)
        addConstraints(withFormat: "V:|-20-[v0]", views: timeLabel)
        addConstraints(withFormat: "V:|-20-[v0]-4-[v1]", views: groupLabel, nameLabel)
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraints(withFormat:"H:|[v0]|", views: dividerLineView)
        addConstraints(withFormat:"V:[v0(1)]|", views: dividerLineView)
    }
    
}
