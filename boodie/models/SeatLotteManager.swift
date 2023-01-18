//
//  TheaterCGVManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

import Foundation
import Alamofire

struct SeatLotte:Codable{
    let Seats: Seat
}
struct Seat:Codable{
    let Items: [Item]
}
struct Item: Codable {
    let ScreenFloor: Int
    let SeatNo: String
    let PhysicalBlockCode, DisplayPhysicalBlockCode, LogicalBlockCode: Int
    let SeatBlockSet, SeatRow: String
    let SeatColumn: Int
    let SeatColumGroupNo, ShowSeatRow: String
    let ShowSeatColumn: Int
    let RelatedSeatNo: String
    let RelatedSeatCount, SeatXCoordinate, SeatYCoordinate, SeatXLength: Int
    let SeatYLength: Int
    let SweetSpotYN: String
    let SeatFloor, FeeBlockCode, SeatStatusCode: Int
    let SalesDisableTicketCode: String
    let CustomerDivisionCode: Int
}


struct SeatLotteManager{
    let url = "http://www.lottecinema.co.kr/LCWS/Ticketing/TicketingData.aspx"
    let headers:HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
    ]
    func fetch(theaterDetail:[String:String], completion: @escaping ([SeatVO]?) -> Void) {
        var param = """
{"MethodName":"GetSeats","channelType":"MW","osType":"W","osVersion":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36","cinemaId":\(theaterDetail["cinemaId"]!),"screenId":\(theaterDetail["screenId"]!),"playDate":"\(theaterDetail["playDate"]!)","playSequence":\(theaterDetail["playSequence"]!),"screenDivisionCode":\(theaterDetail["screenDivisionCode"]!)}
"""
        let params = ["paramList":param]

        performRequest(to: self.url, params: ["paramList":param]) { seats in
            completion(seats)
        }
    }
    func performRequest(to url: String, params: [String: Any], completion: @escaping ([SeatVO]?) -> Void) {
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
//                let str = String(decoding: safeData, as: UTF8.self)
//                print(str)
                // 데이터 분석하기
                if let seats = self.parseJSON(safeData) {
                    completion(seats)
                } else {
                    completion(nil)
                }
            })
    }
    func parseJSON(_ data: Data) ->[SeatVO]? {
        do {
            let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
            let decodedData = try decoder.decode(SeatLotte.self, from: data)
            let list = decodedData.Seats.Items
            let result = list.map{
                SeatVO(left: Double($0.SeatXCoordinate), top: Double($0.SeatYCoordinate),width:Double($0.SeatXLength),height:Double($0.SeatYLength), available: $0.SeatStatusCode == 0 ? true : false, alphabet: $0.ShowSeatRow, no: String($0.SeatColumn))
            }
            return result
        } catch {
            assertionFailure("decoding fail")
            print(error)
            return nil
        }
    }
}
//seatLotteManager.fetch(theaterDetail: self.theaterVO!.theaterDetail!) { seats in
//    if let seats = seats {
//        print(seats)
//    } else {
//        print("좌석 데이터를 받지 못하였습니다.")
//    }
//}
