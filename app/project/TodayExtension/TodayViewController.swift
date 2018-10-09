//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Stanislav Korolev on 01.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var secondsLeft: Int = 0;
    var timer = Timer();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        timeLabel.font = UIFont.systemFont(ofSize: 40)
        
        let date = Date();
        let calendar = Calendar.current;
        let hour = calendar.component(.hour, from: date);
        let minutes = calendar.component(.minute, from: date);
        let second = calendar.component(.second, from: date);
        let toSeconds = ((hour * 60 + minutes) * 60) +  second;
        
        secondsLeft = 86400 - toSeconds;
        
        print("hours = \(hour):\(minutes):\(second)");
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update(){
        
        var hour: Int = 0;
        var minute: Int = 0;
        var second: Int = 0;
        secondsLeft -= 1;
        
        if secondsLeft == 0  || secondsLeft < 0{
            timer.invalidate()
            
        }
        else {
            hour = secondsLeft / 3600
            minute = (secondsLeft % 3600) / 60
            second = (secondsLeft % 3600) % 60
        }
        
        timeLabel.text = "\(hour):\(minute):\(second)";
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

