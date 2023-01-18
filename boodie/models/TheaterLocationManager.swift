//
//  TheaterLocationManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/10.
//

import UIKit
import CoreLocation

protocol TheaterLocationManagerDelegate:AnyObject{
    func theaterLocationManager(_ theater:[TheaterVO]?)
    func theaterLocationManager(dateString:String,adressString:String)
}

class TheaterLocationManager:NSObject{
    
    static let shared = TheaterLocationManager()
    weak var delegate:TheaterLocationManagerDelegate?
    let ad = UIApplication.shared.delegate as! AppDelegate

    override private init(){}
    
    var startUpdatingLocation = false
    var locationManager = CLLocationManager()
    var dateCGVMegaString:String = ""
    var dateLotteString:String = ""
    var dateString = ""

    func fetch(date:Int){
        self.setDate(date)
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.startUpdatingLocation = true
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }else{
                print("위치 권한이 허가되지 않았습니다.")
                self.delegate?.theaterLocationManager(nil)
            }
        }
    }
    
    func fetch(date:Int,latitude:Double,longitude:Double){
        self.setDate(date)
        self.performRequest(latitude: latitude, longitude: longitude)
    }
    
    func performRequest(latitude:Double,longitude:Double){
        
        self.ad.latitude = latitude
        self.ad.longitude = longitude
        
        self.dateLocationParse(latitude:latitude,longitude:longitude)
        let nearListTheaterList = getNearistTheaterList(latitude: latitude, longitude: longitude)
        guard !nearListTheaterList.isEmpty else{
            self.delegate?.theaterLocationManager(nil)
            print("가까운 상영관이 존재하지 않습니다.")
            return
        }
        let theaterCGVManger = TheaterCGVManager()
        let theaterMegaManager = TheaterMegaManager()
        let theaterLotteManager = TheaterLotteManager()

        var theaterVOList:[TheaterVO] = []
        var fetchCount = 0
        nearListTheaterList.forEach {
            let theaterFullName = $0["name"]!
            let latitude2 = Double($0["latitude"]!)!
            let longitude2 = Double($0["longitude"]!)!
            switch $0["type"]!{
            case "CGV":
                let regionCode = $0["regionCode"]!
                let distance = getDistance(latitude1: latitude, longitude1: longitude, latitude2: latitude2, longitude2: longitude2)
                
                let theaterCode = $0["theaterCode"]!
                
                theaterCGVManger.fetch(theaterCd: $0["theaterCode"]!, playYMD: self.dateCGVMegaString) { (theaters) in
                    fetchCount += 1
                    if var theaters = theaters {
                        for i in 0..<theaters.count{
                            theaters[i].theaterFullName = theaterFullName
                            theaters[i].distance = distance
                            theaters[i].theaterCode = theaterCode
                            theaters[i].theaterDetail?["theatercode"] = theaterCode
                            theaters[i].theaterDetail?["theatername"] = theaterFullName
                            theaters[i].theaterDetail?["regionCode"] = regionCode
                        }
                        theaterVOList.append(contentsOf: theaters)
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    } else {
                        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    }
                }
            case "MEGA":
                let distance = getDistance(latitude1: latitude, longitude1: longitude, latitude2: latitude2, longitude2: longitude2)
                theaterMegaManager.fetch(brchNo: $0["cinema"]!, playDe:self.dateCGVMegaString) { (theaters) in
                    fetchCount += 1
                    if var theaters = theaters {
                        for i in 0..<theaters.count{
                            theaters[i].theaterFullName = theaterFullName
                            theaters[i].distance = distance
                        }
                        theaterVOList.append(contentsOf: theaters)
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    } else {
                        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    }
                }
            case "LOTTE":
                let distance = getDistance(latitude1: latitude, longitude1: longitude, latitude2: latitude2, longitude2: longitude2)
                let cinemaId = "\($0["divisionCode"]!)|\($0["detailDivisionCode"]!)|\($0["cinemaID"]!)"
                theaterLotteManager.fetch(cinemaID: cinemaId, playDate: self.dateLotteString) { theaters in
                    fetchCount += 1
                    if var theaters = theaters {
                        for i in 0..<theaters.count{
                            theaters[i].theaterFullName = theaterFullName
                            theaters[i].distance = distance
                        }
                        theaterVOList.append(contentsOf: theaters)
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    } else {
                        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
                        if fetchCount == nearListTheaterList.count{
                            self.delegate?.theaterLocationManager(theaterVOList)
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    func getNearistTheaterList(latitude:Double,longitude:Double)->[[String:String]]{
        var theaterList:[[String:Any]] = []
        let TheaterData = TheaterData()
        TheaterData.cgvList.forEach{
            let x = (latitude-Double($0["latitude"]!)!)*100000.0*0.884
            let y = (longitude-Double($0["longitude"]!)!)*100000.0*1.110
            var theater:[String:Any] = [:]
            $0.forEach{
                theater[$0.key] = $0.value
            }
            theater["distance"] = pow((x*x)+(y*y),0.5)
            theaterList.append(theater)
        }
        TheaterData.megaList.forEach{
            let x = (latitude-Double($0["latitude"]!)!)*100000.0*0.884
            let y = (longitude-Double($0["longitude"]!)!)*100000.0*1.110
            var theater:[String:Any] = [:]
            $0.forEach{
                theater[$0.key] = $0.value
            }
            theater["distance"] = pow((x*x)+(y*y),0.5)
            theaterList.append(theater)
        }
        TheaterData.lotteList.forEach{
            let x = (latitude-Double($0["latitude"]!)!)*100000.0*0.884
            let y = (longitude-Double($0["longitude"]!)!)*100000.0*1.110
            let distance = pow((x*x)+(y*y),0.5)
            guard distance <= 500000 else{return}
            var theater:[String:Any] = [:]
            $0.forEach{
                theater[$0.key] = $0.value
            }
            theater["distance"] = distance
            theaterList.append(theater)
        }
        theaterList.sort{
            return ($0["distance"]! as! Double) < ($1["distance"]! as! Double)
        }
        var nearListTheaterList:[[String:String]] = []
        for i in 0..<5{
            var theater:[String:String] = [:]
            theaterList[i].forEach{
                if $0.key == "distance"{
                    theater[$0.key] = String($0.value as! Double)
                }else{
                    theater[$0.key] = ($0.value as! String)
                }
            }
            nearListTheaterList.append(theater)
        }
        return nearListTheaterList
    }
}
extension TheaterLocationManager:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.startUpdatingLocation else{ return }
        self.startUpdatingLocation = false
        self.locationManager.stopUpdatingLocation()
        
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate{
            self.performRequest(latitude: Double(locValue.latitude), longitude: Double(locValue.longitude))
        } else {
            self.delegate?.theaterLocationManager(nil)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        self.delegate?.theaterLocationManager(nil)
    }
}

extension TheaterLocationManager{
    func dateLocationParse(latitude:Double,longitude:Double){
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                self.delegate?.theaterLocationManager(dateString: self.dateString, adressString: "주소 정보 없음")
                print("Failed to retrieve address")
                return
            }
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let adress = placemark.name{
                    self.delegate?.theaterLocationManager(dateString: self.dateString, adressString: adress)
                }else{
                    self.delegate?.theaterLocationManager(dateString: self.dateString, adressString: "주소 정보 없음")
                }
            }else{
                self.delegate?.theaterLocationManager(dateString: self.dateString, adressString: "주소 정보 없음")
                print("No Matching Address Found")
            }
        })
        

    }
}

//MARK: setDate
extension TheaterLocationManager{
    func setDate(_ date:Int){
        self.ad.date = date 
        
        let now = Date()
        let calendar = Calendar.current
        let dateFormatterCGVMega = DateFormatter()
        dateFormatterCGVMega.dateFormat = "yyyyMMdd"
        
        let dateFormatterLotte = DateFormatter()
        dateFormatterLotte.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd일"
        dayFormatter.locale = Locale(identifier:"ko_KR")
        
        let weekDayFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "(E)"
        weekDayFormatter.locale = Locale(identifier:"ko_KR")
        
        let day = DateComponents(day: date)
        if let formattedDay = calendar.date(byAdding: day, to: now){
            dateCGVMegaString = dateFormatterCGVMega.string(from: formattedDay)
            dateLotteString = dateFormatterLotte.string(from: formattedDay)
            if date == 0{
                self.dateString = "\(dayFormatter.string(from: formattedDay))(오늘)"
            }else{
                self.dateString = "\(dayFormatter.string(from: formattedDay))\(weekDayFormatter.string(from: formattedDay))"
            }
        }
    }
}
extension TheaterLocationManager{
    func getDistance(latitude1:Double,longitude1:Double,latitude2:Double,longitude2:Double)->Double{
        let x = (latitude1-latitude2)*100000.0*0.884
        let y = (longitude1-longitude2)*100000.0*1.110

        return pow((x*x)+(y*y),0.5)
    }
}
