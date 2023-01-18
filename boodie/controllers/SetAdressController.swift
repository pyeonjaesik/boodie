//
//  SetAdressController.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/12.
//

import UIKit
import CoreLocation


class SetAdressController:UIViewController{
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var setAdressBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var latitude:Double?
    var longitude:Double?
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var locationManager = CLLocationManager()
    var startUpdatingLocation = true
    
    lazy var resultAdressBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9)
        button.frame.size.width = 0
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(15))
        return button
    }()
    lazy var resultAdressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "위 주소가 맞다면 검정색 버튼을 클릭하세요."
        label.font = UIFont.systemFont(ofSize: CGFloat(12))
        label.textColor = #colorLiteral(red: 0.1777858436, green: 0.1777858436, blue: 0.1777858436, alpha: 0.7)
        return label
    }()

    override func viewDidLoad() {
        self.searchBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.searchBtn.layer.borderWidth = 0.5
        self.searchBtn.layer.cornerRadius = 4
        
        self.setAdressBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1951935017)
        self.setAdressBtn.layer.borderWidth = 0.5
        self.setAdressBtn.layer.cornerRadius = 4
        
        self.textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)
        self.textField.layer.cornerRadius = 4
        self.textField.layer.borderWidth = 0.5
    }
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func setAdressBtnTapped(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            self.startUpdatingLocation = true
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }else{
            auhthorizeFailUI()
            self.startUpdatingLocation = true
            print("위치 권한이 허가되지 않았습니다.")
        }
    }
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {

        guard let adress = self.textField.text, adress != ""else{return}
        var geometryManager = GeometryManager()
        geometryManager.fetch(adress: adress) { latitude, longitude, adress in
            guard let latitude = latitude, let longitude = longitude else{
                self.configureResultAdressUI(nil)
                return
            }
            
            self.reverseGeocoding(latitude: latitude, longitude: longitude)
        }
    }
    
    @objc func resultAdressBtnTapped(){
        let theaterLocationManager = TheaterLocationManager.shared
        if let latitude = self.latitude, let longitude = self.longitude{
            theaterLocationManager.fetch(date: self.ad.date, latitude: latitude, longitude: longitude)
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    
}
extension SetAdressController{
    func configureResultAdressUI(_ adress:String?){
        if let adress = adress{
            DispatchQueue.main.async {
                self.resultAdressBtn.removeFromSuperview()
                self.view.addSubview(self.resultAdressBtn)
                self.resultAdressBtn.leadingAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32).isActive = true
                self.resultAdressBtn.trailingAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.trailingAnchor, constant: -32).isActive = true
                self.resultAdressBtn.topAnchor.constraint(equalTo:  self.setAdressBtn.bottomAnchor, constant: 16).isActive = true
                self.resultAdressBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
                self.resultAdressBtn.setTitle(adress, for: .normal)
                self.resultAdressBtn.addTarget(self, action: #selector(self.resultAdressBtnTapped), for: .touchUpInside)
                
                self.resultAdressLabel.removeFromSuperview()
                self.view.addSubview(self.resultAdressLabel)
                self.resultAdressLabel.topAnchor.constraint(equalTo:  self.resultAdressBtn.bottomAnchor, constant: 14).isActive = true
                self.resultAdressLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
                self.resultAdressLabel.text = "위 주소가 맞다면 검정색 버튼을 클릭하세요."
            }
        }else{
            DispatchQueue.main.async {
                self.resultAdressBtn.removeFromSuperview()
                self.resultAdressLabel.removeFromSuperview()
                self.view.addSubview(self.resultAdressLabel)
                self.resultAdressLabel.topAnchor.constraint(equalTo:  self.setAdressBtn.bottomAnchor, constant: 16).isActive = true
                self.resultAdressLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
                self.resultAdressLabel.text = "주소를 제대로 입력해 주세요."
            }
        }
    }
    func auhthorizeFailUI(){
        DispatchQueue.main.async {
            self.resultAdressBtn.removeFromSuperview()
            self.resultAdressLabel.removeFromSuperview()
            self.view.addSubview(self.resultAdressLabel)
            self.resultAdressLabel.topAnchor.constraint(equalTo:  self.setAdressBtn.bottomAnchor, constant: 16).isActive = true
            self.resultAdressLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            self.resultAdressLabel.text = "위치 권한을 허용해 주세요."
        }
    }
}
//MARK: reverseGEOCODING & getAdress
extension SetAdressController{
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = Double(latitude)
        self.longitude = Double(longitude)
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Failed to retrieve address")
                return
            }
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let adress = placemark.name{
                    self.configureResultAdressUI(adress)
                }else{
                    self.configureResultAdressUI(nil)
                }
            }else{
                print("No Matching Address Found")
                self.configureResultAdressUI(nil)
            }
        })
    }

}
//MARK: CLLocationManagerDelegate
extension SetAdressController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.startUpdatingLocation else{ return }
        self.startUpdatingLocation = false
        self.locationManager.stopUpdatingLocation()
        
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate{
            reverseGeocoding(latitude: Double(locValue.latitude), longitude: Double(locValue.longitude))
        } else {
            
        }
    }
}
