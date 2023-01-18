//
//  TheaterCGVManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

import Foundation

struct SeatMega:Codable{
    let seatListSD01:[SeatListSD01]
}
struct SeatListSD01:Codable{
//    let smapBaseNo: Int
//    let seatUniqNo, seatZoneCD, seatClassCD: String
////    let seatSellChnlCD: JSONNull?
//    let seatSellTyCD: String
////    let seatGrpNo: JSONNull?
//    let sellPrirRank: Int
    let rowNm: String
    let seatNo:Int
//    let rowNo, colNo: Int
//    let seatDispTyCD: String
////    let gateTyCD: JSONNull?
//    let seatExpoAt: String
    let horzCoorVal, vertCoorVal:Double
    let horzSizeRt:Double
    let horzPosiRt: Double
    let vertPosiRt: Double
//    let seatNotiMsg: JSONNull?
//    let seatChoiGrpSeq: Int
//    let seatChoiGrpNm: String
//    let seatChoiGrpNo, seatChoiRowCnt: Int
//    let seatChoiDircVal, fstRegDt: String
//    let fstRegrNo: Int
//    let lstUptDt: String
//    let lstUptrNo: Int
//    let rowStatCD: String
    let seatStatCd: String
}

struct SeatMegaManager{
    let url = "https://www.megabox.co.kr/on/oh/ohz/PcntSeatChoi/selectSeatList.do?playSchdlNo="

    func fetch(theaterDetail:[String:String], completion: @escaping ([SeatVO]?) -> Void) {
        performRequest(with: self.url+theaterDetail["playSchdlNo"]!) { seats in
            completion(seats)
        }
    }
    func performRequest(with urlString: String, completion: @escaping ([SeatVO]?) -> Void) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)


//        guard let paramData = param.data(using: .utf8)else{
//            NSLog("TheaterMegaManager paramData가 nil 입니다.")
//            return
//        }

        request.httpMethod = "POST"
//        request.httpBody = paramData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

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
            // 데이터 분석하기
            if let seats = self.parseJSON(safeData) {
                completion(seats)
            } else {
                completion(nil)
            }

        }
        task.resume()

    }
    func parseJSON(_ data: Data) ->[SeatVO]? {
        do {
            let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
            let decodedData = try decoder.decode(SeatMega.self, from: data)
            let list = decodedData.seatListSD01
            let result = list.map{
                SeatVO(left: Double($0.horzCoorVal), top: $0.vertCoorVal,width: Double($0.horzSizeRt),height:Double(1), available: $0.seatStatCd == "GERN_SELL" ? true : false, alphabet: String($0.rowNm), no: String($0.seatNo))
            }
            return result
        } catch {
            let str = String(decoding: data, as: UTF8.self)
//            print(str)
            print(error)
            assertionFailure("Aa")
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
