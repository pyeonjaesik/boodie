# 부디 - 근처 영화관의 상영시간표를 한눈에 보여주는 앱.

**[작업 기간]** 

   2023.01.09 ~ 2023.01.17 (9일)

**[기여도]**

  기획&디자인 90 , 개발 100


### **[프로젝트 설명]**

  ‘부디’는 사용자 위치 기반으로 **근처 영화관의 상영시간표를 한눈에** 보여주고 사용자의 관람성향을 파악하여 **좌석과 상영관을 추천**해주는 앱입니다. 2019년 8월에 크로스 플랫폼 앱(react native)로 개발되어 출시된 후, 2023년 1월에 네이티브 앱으로 재탄생 하였습니다. 출시 후에도 사용자의 피드백을 받아 꾸준히 고도화한 서비스이며, 상영관 추천 알고리즘을 직접 개발하여 특허를 등록하기도 하였습니다.

![%E1%84%87%E1%85%AE%E1%84%83%E1%85%B5%E1%84%80%E1%85%A2%E1%84%8B%E1%85%AD](https://user-images.githubusercontent.com/38762911/213625542-bae9fa34-a476-4579-bca9-6f5455eac9d2.png)

[https://www.youtube.com/watch?v=8XZ1-BrJiZk](https://www.youtube.com/watch?v=8XZ1-BrJiZk)

### **[내가 쓰고 싶어 만든 앱으로 플레이스토어 신규 TOP100을 달성하다.]**

개인적으로 영화관에서 영화를 보는 것을 굉장히 좋아했었는데, 영화관 3사의 사이트에 일일이 들어가 상영시간표를 확인하는 것이 번거롭다고 생각하였습니다. ‘부디’는 본인의 번거로운 경험을 기반으로 시작된 프로젝트입니다. 본인 스스로가 고객의 입장이 되어 페인포인트를 공감,분석하였기 때문에 이 앱은 영화 커뮤니티에서 뜨거운 반응을 얻을 수 있었고, 마침내 **플레이스토어 신규 TOP100**을 달성할 수 있었습니다. 

![Frame_2](https://user-images.githubusercontent.com/38762911/213625658-a0782a73-90b0-491c-83f4-52f65ddf8e11.png)


### **[운영비용이 들지 않는 앱, 부디]**

적은 운영비용으로 앱을 출시하는 것을 목표로 하였습니다. 이는 운영비용이 드는 DB 구축 방식이 아닌, 모바일 기기에서 각 사이트의 상영관 데이터를 크롤링하는 방식으로 해결하였습니다. 모바일 기기에서 다이렉트로 상영관 정보를 크롤링하여 가져오기에, 운영 비용은 들지 않았고 대용량 트래픽에 대해서도 걱정하지 않아도 되었습니다.

![Frame_3_(1)](https://user-images.githubusercontent.com/38762911/213625707-4a6fdb3a-dfd9-4ee5-82ed-77e9b50b290f.png)


> 저는 이렇게 코드를 짰어요.
> 

**사용한 라이브러리 & 프레임 워크:** SwiftSoup, Alamofire, CoreLocation

**STEP 1)** CGV, 롯데시네마, 메가박스의 상영 정보를 받아오는 코드를 객체지향 패러다임을 준수하여 코드를 작성하였습니다.

- TheaterCGVManager - CGV의 상영정보를 가져오는 객체.
    
    ```swift
    import Foundation
    import SwiftSoup
    
    struct TheaterCGVManager{
        let url = "https://m.cgv.co.kr/Schedule/cont/ajaxMovieSchedule.aspx"
        
        func fetch(theaterCd: String,playYMD:String, completion: @escaping ([TheaterVO]?) -> Void) {
            let param = "theaterCd=\(theaterCd)&playYMD=\(playYMD)"
            guard let paramData = param.data(using: .utf8)else{
                NSLog("TheaterCGVManager paramData가 nil 입니다.")
                return
            }
            performRequest(with: url, paramData:paramData) { movies in
                completion(movies)
            }
        }
        func performRequest(with urlString: String,paramData:Data, completion: @escaping ([TheaterVO]?) -> Void) {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = paramData
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
            let task = URLSession.shared.dataTask(with: request) {
                   (data, response, error) in
                   
                if error != nil {
                    print(error!)
                    completion(nil)
                    return
                }
                
                guard let safeData = data else {
                    completion(nil)
                    return
                }
                
                // 데이터 분석하기
                if let theaters = self.parseDom(safeData) {
                    completion(theaters)
                } else {
                    completion(nil)
                }
    
        }
        task.resume()
    
        }
        func parseDom(_ movieData: Data)->[TheaterVO]?{
            let str = String(decoding: movieData, as: UTF8.self)
            do {
                let doc: Document = try SwiftSoup.parse(str)
                let elements = try doc.select(".Btn_lightGrey")
                let result: [TheaterVO] = try elements.map{
                    let theaterData = try $0.attr("href").description.split(separator: "'")
                    let theaterDetail:[String:String] = [
                        "palyymd":String(theaterData[14]),
                        "screencode":String(theaterData[18]),
                        "playnum":String(theaterData[16]),
                        "starttime":String(theaterData[28]),
                        "endtime":String(theaterData[32]),
                        "cnt":String(theaterData[7]),
                        "screenname":String(theaterData[3]),
                    ]
                    return TheaterVO(company: "CGV", theaterCode: "", theaterName: "", theaterSubtitle: String(theaterData[3]), theaterStyle: "", theaterStyleSubtitle: "", playStartTime: String(theaterData[5]), playEndTime: "", movieName: String(theaterData[1]), movieNo: "", restSeatCnt: Int(theaterData[7])!, totalSeatCnt: Int(theaterData[9])!,theaterDetail: theaterDetail)
                }
                return result
           
            } catch Exception.Error(let type, let message) {
                print(message)
                assertionFailure(message)
                return nil
            } catch {
                assertionFailure("theaterCGVManager parse DOM fail")
                print("error")
                return nil
            }
        }
    }
    ```
    
- TheaterLotteManager - 롯데시네마의 상영정보를 가져오는 객체.
    
    ```swift
    import Foundation
    import Alamofire
    struct LotteList: Codable {
        let PlaySeqs: PlaySeq
    }
    
    // MARK: - PlaySeqs
    struct PlaySeq: Codable {
        let Items: [Items]
    }
    
    // MARK: - Item
    struct Items: Codable {
        let CinemaNameKR: String
        let MovieNameKR: String
        let ViewGradeCode: Int
        let FilmNameKR: String
        let SoundTypeNameKR: String
        let PosterURL: String?
        let ScreenFloor: String?
        let MovieCode: String
        let StartTime, EndTime: String
        let TotalSeatCount, BookingSeatCount:Int
        let ScreenNameKR:String
        let AccompanyTypeNameKR:String // 일반
        let SequenceNoGroupNameKR:String //조조
        let CinemaID: Int
        let ScreenID:Int
        let PlaySequence:Int
        let ScreenDivisionCode:Int
        let PlayDt:String
        let RepresentationMovieCode:String
    }
    
    struct TheaterLotteManager{
        
        let url = "https://www.lottecinema.co.kr/LCWS/Ticketing/TicketingData.aspx"
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        func fetch(cinemaID: String, playDate:String, completion: @escaping ([TheaterVO]?) -> Void) {
            let param = """
        {"MethodName":"GetPlaySequence","channelType":"HO","osType":"Chrome","osVersion":"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Mobile Safari/537.36","playDate":"\(playDate)","cinemaID":"\(cinemaID)","representationMovieCode":""}
        """
            performRequest(to: self.url, params: ["paramList":param]) { movies in
                completion(movies)
            }
        }
        func performRequest(to url: String, params: [String: Any], completion: @escaping ([TheaterVO]?) -> Void) {
    
            AF.upload(multipartFormData: { multiPart in
                for (key, value) in params {
                    if let temp = value as? String {
                        multiPart.append(temp.data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Int {
                        multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? NSArray {
                        temp.forEach({ element in
                            let keyObj = key + "[]"
                            if let string = element as? String {
                                multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                            } else
                                if let num = element as? Int {
                                    let value = "\(num)"
                                    multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                            }
                        })
                    }
                }
            }, to: url, usingThreshold: UInt64.init(), method: .post, headers: self.headers)
                .responseJSON(completionHandler: { data in
                    if data.error != nil {
                        print(data.error!)
                        completion(nil)
                        return
                    }
                    
                    guard let safeData = data.data else {
                        completion(nil)
                        return
                    }
                    // 데이터 분석하기
                    if let theaters = self.parseJSON(safeData) {
                        completion(theaters)
                    } else {
                        completion(nil)
                    }
                })
        }
        func parseJSON(_ movieData: Data) ->[TheaterVO]? {
            do {
                let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
                let decodedData = try decoder.decode(LotteList.self, from: movieData)
                let list = decodedData.PlaySeqs.Items
                let result = list.map{
                    let theaterDetail = [
                        "cinemaId": String($0.CinemaID),
                        "screenId": String($0.ScreenID),
                        "playDate": String($0.PlayDt),
                        "playSequence": String($0.PlaySequence),
                        "screenDivisionCode": String($0.ScreenDivisionCode),
                        "RepresentationMovieCode": String($0.RepresentationMovieCode)
                    ]
                    return TheaterVO(company: "롯데시네마", theaterCode: String($0.CinemaID), theaterName: $0.CinemaNameKR, theaterSubtitle: $0.ScreenNameKR, theaterStyle: $0.AccompanyTypeNameKR, theaterStyleSubtitle: $0.SequenceNoGroupNameKR, playStartTime: $0.StartTime, playEndTime: $0.EndTime, movieName: $0.MovieNameKR, movieNo: $0.MovieCode, restSeatCnt: $0.BookingSeatCount, totalSeatCnt: $0.TotalSeatCount,theaterDetail: theaterDetail)
                }
                return result
                
            } catch {
                assertionFailure("theaterLotteManager decoding fail")
                print(error)
                return nil
            }
        }
    }
    ```
    
- TheaterMegaManager - 메가박스의 상영정보를 가져오는 객체.
    
    ```swift
    import Foundation
    struct List: Codable {
        let megaMap: MegaMap
    }
    
    // MARK: - MegaMap
    struct MegaMap: Codable {
        let movieFormList: [MovieFormList]
    }
    
    // MARK: - MovieFormList
    struct MovieFormList: Codable {
        let brchNo: String
        let brchNm: String
        let playSchdlNo, theabNo: String
        let theabExpoNm: String
        let theabSeatCnt: Int
        let playStartTime, playEndTime: String
        let movieNm, movieNo: String
        let playKindNm: String
        let playTyCdNm: String? //조조
        let restSeatCnt, totSeatCnt: Int
        let playDe: String
        let rpstMovieNo: String
    }
    
    struct TheaterMegaManager{
        let url = "https://megabox.co.kr/on/oh/ohc/Brch/schedulePage.do"
        func fetch(brchNo: String,playDe:String, completion: @escaping ([TheaterVO]?) -> Void) {
            let param = "brchNo&=\(brchNo)&playDe=\(playDe)&brchNo1=\(brchNo)"
            guard let paramData = param.data(using: .utf8)else{
                NSLog("TheaterMegaManager paramData가 nil 입니다.")
                return
            }
            performRequest(with: url, paramData:paramData) { movies in
                completion(movies)
            }
        }
        func performRequest(with urlString: String,paramData:Data, completion: @escaping ([TheaterVO]?) -> Void) {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = paramData
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
            
            let task = URLSession.shared.dataTask(with: request) {
                    (data, response, error) in
                if error != nil {
                    print(error!)
                    completion(nil)
                    return
                }
                
                guard let safeData = data else {
                    completion(nil)
                    return
                }
                // 데이터 분석하기
                if let theaters = self.parseJSON(safeData) {
                    completion(theaters)
                } else {
                    completion(nil)
                }
                
            }
            task.resume()
    
        }
        func parseJSON(_ movieData: Data) ->[TheaterVO]? {
            do {
                let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
                let decodedData = try decoder.decode(List.self, from: movieData)
                let list = decodedData.megaMap.movieFormList
                let result = list.map{
                    let theaterDetail = [
                        "playSchdlNo":$0.playSchdlNo,
                        "rpstMovieNo":$0.rpstMovieNo
                    ]
                    let movieNm = $0.movieNm.contains(";") ? String($0.movieNm.split(separator: ";")[$0.movieNm.split(separator: ";").count-1]) : $0.movieNm
                    return TheaterVO(company: "메가박스", theaterCode: $0.brchNo, theaterName: $0.brchNm, theaterSubtitle: $0.theabExpoNm, theaterStyle: String.removeSpecialCharacter($0.playKindNm), theaterStyleSubtitle: $0.playTyCdNm, playStartTime: $0.playStartTime, playEndTime: $0.playEndTime, movieName: movieNm, movieNo: $0.movieNo, restSeatCnt: $0.restSeatCnt, totalSeatCnt: $0.totSeatCnt,theaterDetail:theaterDetail)
                }
                return result
            } catch {
                print(error)
                assertionFailure("theaterMegaManger decoding fail")
                return nil
            }
        }
    }
    ```
    

**STEP 2)** 유저의 위치를 기반으로 3사의 상영 정보를 가져오는 객체를 만들었습니다. 

- TheaterLocationManager - 위치를 기반으로 3사의 상영정보를 가져오는 객체.
    
    ```swift
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
    
    ```
    

**STEP 3)** 상영정보를 가져오는 controller에서 TheaterLocationManager 를 싱글톤 객체로 생성하게 한 후, 델리게이트 패턴으로 정보를 받아올 수 있게 조치하였습니다. 
*(ViewController에서만 상영정보를 보여주면 되고, 다른 화면(controller)에서 델리게이트 매서드를 호출하여 ViewController에 상영정보를 표시해 주어야 하기 때문에 **싱글톤&델리게이트 패턴**으로 코드를 작성하였습니다.)*

- ViewController - 상영 정보를 보여주는 Controller
    
    ```swift
    extension ViewController:TheaterLocationManagerDelegate{
        func theaterLocationManager(dateString: String, adressString: String) {
            self.theaterListEmptyLabel.removeFromSuperview()
            self.requestLocationAthourizationButton.removeFromSuperview()
            self.requestLocationAthourizationView.removeFromSuperview()
            
            self.setDateBtn.setTitle(" \(dateString)", for: .normal)
            self.setAdressBtn.setTitle(" \(adressString)", for: .normal)
            if dateString.contains("오늘"){
                self.setDateBtn.setTitleColor(#colorLiteral(red: 0.07450980392, green: 0.6470588235, blue: 0.2196078431, alpha: 1), for: .normal)
            }
      
        }
        func theaterLocationManager(_ theater: [TheaterVO]?) {
            if let theater = theater{
                if theater.isEmpty{
                    // 상영 정보가 없음.
                    DispatchQueue.main.async {
                        self.view.addSubview(self.theaterListEmptyLabel)
                        self.theaterListEmptyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                        self.theaterListEmptyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    }
                }else{
                    self.theaterList = ParseTheaterList().parse(theater)
                    self.titleList = self.theaterList.map{
                        Array($0.values)[0][0].movieName
                    }
                    self.fetchSecondPoster()
                    self.configureCollectionView()
                }
            }else{
                DispatchQueue.main.async {
                    self.view.addSubview(self.requestLocationAthourizationView)
                    self.requestLocationAthourizationView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                    self.requestLocationAthourizationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    
                    self.view.addSubview(self.requestLocationAthourizationButton)
                    self.requestLocationAthourizationButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    self.requestLocationAthourizationButton.topAnchor.constraint(equalTo: self.requestLocationAthourizationView.bottomAnchor, constant: 32).isActive = true
                    self.requestLocationAthourizationButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
                    self.requestLocationAthourizationButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
                }
                
                print("위치 권한을 허용해 주세요.")
            }
        }
    }
    ```
    

**STEP 4)** 유저의 위치나 조회 날짜를 변경하는 변경하는 화면(controller)에서 TheaterLocationManager 의 싱글톤 인스턴스를 가져와 메소드를 호출하는 간단한 코드만으로 상영정보를 받아 오게 하였습니다.

- SetDateController - 조회 날짜를 변경하는 화면
    
    ```swift
    let locationManager = TheaterLocationManager.shared
    //locationManager 인스턴스를 다른 함수에서도 사용하므로, 클래스의 프라퍼티로 선언하였습니다.
    
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
    ```
    
- SetAdressController - 조회 위치를 변경하는 화면
    
    ```swift
    @objc func resultAdressBtnTapped(){
            let theaterLocationManager = TheaterLocationManager.shared
    				// theaterLocationManager를 함수 내부에서 사용하므로, 함수 내부에서 인스턴스를 선언하였습니다.
            if let latitude = self.latitude, let longitude = self.longitude{
                theaterLocationManager.fetch(date: self.ad.date, latitude: latitude, longitude: longitude)
                self.presentingViewController?.dismiss(animated: true)
            }
        }
    ```
    

**STEP5)** 리스트에 보여줄 이미지를 비동기 방식으로 다운로드하고, 메모이제이션하여 성능을 높였습니다.

- 이미지 다운로드 코드.
    
    ```swift
    var posters:[String:PosterVO] = [:]
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCell
    
          //
    			(코드 생략.)
    			//
    
          if self.posters[Array(self.theaterList[indexPath.row].keys)[0]] == nil{
              self.posterManager.fetch(Array(self.theaterList[indexPath.row].values)[0]) { posterVO in
                  cell.posterVO = posterVO
                  self.posters[Array(self.theaterList[indexPath.row].keys)[0]] = posterVO
              }
          }else{
              cell.posterVO = self.posters[Array(self.theaterList[indexPath.row].keys)[0]]
          }
          return cell
    }
    ```
    

### **[사용자의 피드백을 반영하여 상영관 추천 시스템을 개발하다]**

사용자가 상영관을 선택하면 최적의 좌석을 추천해주고, 나아가 외부 상영관과 해당상영관을 비교하여 더 좋은 것을 추천하는 기능을 제공하였습니다. 고객 경험 이해 및 향상을 위해 30명 이상의 사용자에게 정성 인터뷰를 진행하여, 유저가 어떤 기준으로 좌석을 선택하는지 연구하였습니다. 그 결과 좌석이 어떤 위치에 있는지, 옆 좌석이 얼마나 점유 되었는지, 상영 중 화장실 이용이 얼마나 편리한지 등의 기준으로 좌석을 선택한다는 것을 알 수 있었습니다. 이러한 정보를 토대로 좌석별로 점수를 매겨 사용자에게 선택지를 추천하는 알고리즘을 개발하였습니다. 나아가 제일 좋은 좌석의 점수를 상영관에 매겨, 점수를 기반으로 상영관까지 함께 추천해주었습니다.

![Frame_5_(1)](https://user-images.githubusercontent.com/38762911/213625851-66fb91db-f9b7-4365-95da-84ed5408a5c5.png)


> 저는 이렇게 상영관 추천 알고리즘을 만들었어요.
> 

![Frame_4_(1)](https://user-images.githubusercontent.com/38762911/213625870-444823e1-4a45-4491-85f5-67e7b6fbf250.png)


![Frame_4_(2)](https://user-images.githubusercontent.com/38762911/213625893-5ed4807d-4975-434b-a308-5f5982c9b3fa.png)


### [google play store의 탭뷰에 착안하여, 부드럽고 직관적인 화면을 그리다]

부디가 고객에게 제공하는 핵심 가치는 ‘손쉽고 빠르게 , 그리고 직관적으로 상영정보 제공하는 것’입니다. 이를 위해 google play store의 탭뷰에 착안하여 화면을 구성하였습니다.

(부디 탭뷰 영상)

[](https://www.youtube.com/shorts/_TJqbdefRqc)

> 저는 코드를 이렇게 짰어요.


![Frame_6](https://user-images.githubusercontent.com/38762911/213625911-b7129a6b-17b2-45a2-9f58-407d1d2796d5.png)


**STEP 1)** MainCollectionView의 스크롤을 감지하여, HeaderCollectionView를 스크롤하고, HeaderCollectionView의 셀을 선택 처리합니다.

- step 1. 코드
    
    ```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    	  if scrollView == self.mainCollectionView{
    	      // 
    				(코드 생략...)
    				//
    	      let scrollIndex =  Int(self.mainCollectionView.bounds.origin.x)%Int(view.frame.width)
    	      if scrollIndex < 1 || scrollIndex > Int(view.frame.width) - 1{
    	          let newFocusedRow = Int(round(self.mainCollectionView.bounds.origin.x/view.frame.width))
    	          if newFocusedRow != self.focusedRow{
    	              self.focusedRow = newFocusedRow
    	              self.focusedMovieName = Array(self.theaterList[newFocusedRow].keys)[0]
    	              let indexPath = IndexPath(row: self.focusedRow, section: 0)
    	              self.headerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    	              self.headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    	          }
    	      }
    	  }else if scrollView == self.headerCollectionView{
    	      self.Indicator.bounds.origin.x = self.headerCollectionView.bounds.origin.x
    	  }
    }
    ```
    

**STEP 2)** MainCollectionView를 스크롤한 만큼, 비율에 맞춰 Indicator Bar의 origin.x를 설정합니다.

- step 2. 코드
    
    ```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView == self.mainCollectionView{
                let leftRow = Int(self.mainCollectionView.bounds.origin.x/view.frame.width)
                let rightRow = Int(ceil(self.mainCollectionView.bounds.origin.x/view.frame.width))
                let leftTitleWidth = self.titleList[leftRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[leftRow].count*self.titleMutipleSize+self.titlePaddingSize
                let rightTitleWidth = self.titleList[rightRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[rightRow].count*self.titleMutipleSize+self.titlePaddingSize
                
                
                var totalWidth = 0
                for i in 0..<leftRow{
                    let textWidth = self.titleList[i].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[i].count*self.titleMutipleSize+self.titlePaddingSize
                    totalWidth += textWidth
                }
                self.bar.frame.origin.x = CGFloat(totalWidth) + (self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width))*CGFloat(leftTitleWidth)/view.frame.width
                
              // 
    					(코드 생략...)
    					//
            }else if scrollView == self.headerCollectionView{
                self.Indicator.bounds.origin.x = self.headerCollectionView.bounds.origin.x
            }
        }
    ```
    

**STEP 3)** 선택될 HeaderCollectionView 셀의 가로 사이즈에 맞춰 Indicator Bar의 width를 설정합니다.

- step 3. 코드
    
    ```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainCollectionView{
            let leftRow = Int(self.mainCollectionView.bounds.origin.x/view.frame.width)
            let rightRow = Int(ceil(self.mainCollectionView.bounds.origin.x/view.frame.width))
            let leftTitleWidth = self.titleList[leftRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[leftRow].count*self.titleMutipleSize+self.titlePaddingSize
            let rightTitleWidth = self.titleList[rightRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[rightRow].count*self.titleMutipleSize+self.titlePaddingSize
            
             // 
    				 (코드 생략...)
    			   //
    
          
            let transition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            if transition.x < 0{
                self.bar.frame.size.width = CGFloat(leftTitleWidth) + CGFloat(rightTitleWidth-leftTitleWidth)*self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width)/view.frame.width
            }else{
                self.bar.frame.size.width = CGFloat(rightTitleWidth) + CGFloat(leftTitleWidth-rightTitleWidth)*(1.0-self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width)/view.frame.width)
            }
    
             // 
    				 (코드 생략...)
    			   //
            
    
        }else if scrollView == self.headerCollectionView{
            self.Indicator.bounds.origin.x = self.headerCollectionView.bounds.origin.x
        }
    }
    ```
    

**STEP 4)** HeaderCollectionView를 스크롤한 만큼 Indcator Bar도 같이 이동될 수 있도록 조치합니다.

- step 4. 코드
    
    ```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView == self.mainCollectionView{
    					//
    					(코드 생략...)
    					//
            }else if scrollView == self.headerCollectionView{
                self.Indicator.bounds.origin.x = self.headerCollectionView.bounds.origin.x
            }
        }
    ```
    

**STEP 5)** MainCollectionView를 빠르게 스크롤 했을 때, HeaderCollection View 또한 부드럽게 스크롤될 수 있도록 조치합니다. 이는 MainCollectionView의 스크롤 드래그를 끝냈을 때 HeaderCollectionView를 스크롤해 주는 것으로 해결하였습니다.

- step 5. 코드
    
    ```swift
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if scrollView == self.mainCollectionView{
                let newFocusedRow = Int(round(self.mainCollectionView.bounds.origin.x/view.frame.width))
                if newFocusedRow != self.focusedRow{
                    self.focusedRow = newFocusedRow
                    self.focusedMovieName = Array(self.theaterList[newFocusedRow].keys)[0]
                    let indexPath = IndexPath(row: self.focusedRow, section: 0)
                    self.headerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
    ```
    

**STEP 6)**HeaderCollectionView의 셀을 클릭 했을 때 MainScrollView 또한 스크롤될 수 있도록 조치합니다.

- step 6. 코드![%E1%84%87%E1%85%AE%E1%84%83%E1%85%B5%E1%84%80%E1%85%A2%E1%84%8B%E1%85%AD](https://user-images.githubusercontent.com/38762911/213625328-b7ee0c47-6e84-49d4-b1a8-09c1e9fbdcd8.png)
    
    ```swift
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == headerCollectionView{
                self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    ```
    

### **[고객이 진정으로 원하는 서비스가 무엇인지 몸소 배우다]**

좌석 추천 기능 외에 특별관을 기준으로 전국의 모든 상영관을 추천해주는 기능을 함께 개발한 적이 있습니다. 하지만 이 기능은 다소 반응이 좋지 않았습니다. 부디의 본질적인 가치인 ‘근처 영화관을 쉽고 빠르게 추천한다’는 본질과 다른 성격의 서비스였기 때문이라 생각합니다. 이러한 경험을 바탕으로 서비스 초기에 일관되고 핵심적인 가치를 제공해야 하며, 아이덴티티가 다른 서비스 개발을 위해서는 기존 서비스가 확실히 궤도화, 안정화 된 후 고려하는 것이 좋다 라는 점을 깨닫게 되었습니다.
