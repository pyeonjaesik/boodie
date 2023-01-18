//
//  TheaterCGVManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

import Foundation
import SwiftSoup

struct SeatCGV:Codable{
    let d:String
}

struct SeatCGVManager{
    let url = "http://www.cgv.co.kr/common/showtimes/iframeTheater.aspx/GetSeatList"

    func fetch(theaterDetail:[String:String], completion: @escaping ([SeatVO]?) -> Void) {
        let param = "{theatercode: '\(theaterDetail["theatercode"]!)',  palyymd : '\(theaterDetail["palyymd"]!)', screencode : '\(theaterDetail["screencode"]!)' , playnum : '\(theaterDetail["playnum"]!)', starttime : '\(theaterDetail["starttime"]!)', endtime : '\(theaterDetail["endtime"]!)', theatername : '\(theaterDetail["theatername"]!)', cnt : '\(theaterDetail["cnt"]!)', screenname : '\(theaterDetail["screenname"]!)'}"
        guard let paramData = param.data(using: .utf8)else{
            NSLog("TheaterCGVManager paramData가 nil 입니다.")
            return
        }
        performRequest(with: url, paramData:paramData) { seats in
            completion(seats)
        }
    }
    func performRequest(with urlString: String,paramData:Data, completion: @escaping ([SeatVO]?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = paramData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
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
//            let str = String(decoding: safeData, as: UTF8.self)
//            print(str)
            if let seats = self.parseDom(safeData) {
                completion(seats)
            } else {
                completion(nil)
            }

    }
    task.resume()

    }
    func parseDom(_ data: Data)->[SeatVO]?{
        do{
            let alphabet:[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                  "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
            let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
            let decodedData = try decoder.decode(SeatCGV.self, from: data)
            var str = decodedData.d.filter{
                return String($0) != "\\"
            }.map{String($0)}.joined()
            let doc: Document = try SwiftSoup.parse(str)
            let elements = try doc.select(".mini_seats > div")
            let result = try elements.map{
                let available = try $0.className().contains("reserved") ? false : true
                let style = try $0.attr("style").description
                let left = Int(style.split(separator: ":")[1].split(separator: "p")[0])! * 4
                let top = Int(style.split(separator: ":")[2].split(separator: "p")[0])! * 4
                return SeatVO(left: Double(left), top: Double(top),width:Double(16),height:Double(16), available: available, alphabet: alphabet[top/16], no: String(left/16))
            }
            return result
        }catch{
            assertionFailure("decoding fail")
            print(error)
            return nil
        }
    }
}
//seatCGVManager.fetch(theaterDetail: theaterVO!.theaterDetail!) { seats in
//    if let seats = seats {
//        print(seats)
//    } else {
//        print("좌석 데이터를 받지 못하였습니다.")
//    }
//}
