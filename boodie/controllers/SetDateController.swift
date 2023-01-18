//
//  SetDateController.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/12.
//

import UIKit

class SetDateContoller:UIViewController{
    
    @IBOutlet weak var dateYesterdayBtn: UIButton!
    @IBOutlet weak var date0Btn: UIButton!
    @IBOutlet weak var date1Btn: UIButton!
    @IBOutlet weak var date2Btn: UIButton!
    @IBOutlet weak var date3Btn: UIButton!
    @IBOutlet weak var date4Btn: UIButton!
    @IBOutlet weak var date5Btn: UIButton!
    
    var index = true
    let locationManager = TheaterLocationManager.shared
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        let now = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 dd일(E)"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        if let formattedDay = calendar.date(byAdding: DateComponents(day: -1), to: now){
            self.dateYesterdayBtn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 0), to: now){
            self.date0Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 1), to: now){
            self.date1Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
            let week = Calendar.current.dateComponents([.weekday], from: formattedDay).weekday!
            if week == 7{
                self.date1Btn.tintColor = #colorLiteral(red: 0.1764705882, green: 0.4470588235, blue: 0.8509803922, alpha: 1)
            }else if week == 1{
                self.date1Btn.tintColor = #colorLiteral(red: 0.9176470588, green: 0.262745098, blue: 0.2078431373, alpha: 1)
            }
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 2), to: now){
            self.date2Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
            let week = Calendar.current.dateComponents([.weekday], from: formattedDay).weekday!
            if week == 7{
                self.date2Btn.tintColor = #colorLiteral(red: 0.1764705882, green: 0.4470588235, blue: 0.8509803922, alpha: 1)
            }else if week == 1{
                self.date2Btn.tintColor = #colorLiteral(red: 0.07450980392, green: 0.6470588235, blue: 0.2196078431, alpha: 1)
            }
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 3), to: now){
            self.date3Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
            let week = Calendar.current.dateComponents([.weekday], from: formattedDay).weekday!
            if week == 7{
                self.date3Btn.tintColor = #colorLiteral(red: 0.1764705882, green: 0.4470588235, blue: 0.8509803922, alpha: 1)
            }else if week == 1{
                self.date3Btn.tintColor = #colorLiteral(red: 0.9176470588, green: 0.262745098, blue: 0.2078431373, alpha: 1)
            }
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 4), to: now){
            self.date4Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
            let week = Calendar.current.dateComponents([.weekday], from: formattedDay).weekday!
            if week == 7{
                self.date4Btn.tintColor = #colorLiteral(red: 0.1764705882, green: 0.4470588235, blue: 0.8509803922, alpha: 1)
            }else if week == 1{
                self.date4Btn.tintColor = #colorLiteral(red: 0.9176470588, green: 0.262745098, blue: 0.2078431373, alpha: 1)
            }
        }
        if let formattedDay = calendar.date(byAdding: DateComponents(day: 5), to: now){
            self.date5Btn.setTitle(dateFormatter.string(from: formattedDay), for: .normal)
            let week = Calendar.current.dateComponents([.weekday], from: formattedDay).weekday!
            if week == 7{
                self.date5Btn.tintColor = #colorLiteral(red: 0.1764705882, green: 0.4470588235, blue: 0.8509803922, alpha: 1)
            }else if week == 1{
                self.date5Btn.tintColor = #colorLiteral(red: 0.9176470588, green: 0.262745098, blue: 0.2078431373, alpha: 1)
            }
        }

    }
    
    @IBAction func dateYesterdayBtnTapped(_ sender: UIButton) {
        guard self.index else{ return }
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:-1,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:-1)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func date0BtnTapped(_ sender: UIButton) {
        guard self.index else{ return }
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:0,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:0)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func date1BtnTapped(_ sender: UIButton) {
        guard self.index else{ return }
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:1,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:1)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func date2BtnTapped(_ sender: UIButton) {
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:2,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:2)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func date3BtnTapped(_ sender: UIButton) {
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:3,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:3)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func date4BtnTapped(_ sender: UIButton) {
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:4,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:4)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func date5BtnTapped(_ sender: UIButton) {
        self.index = false
        if let latitude = self.ad.latitude, let longitude = self.ad.longitude{
            locationManager.fetch(date:5,latitude: latitude,longitude: longitude)
        }else{
            locationManager.fetch(date:5)
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func closBtnTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}
