//
//  TheaterLotteManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

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
//        let cinemaID = "1|1|1013"
//        let playDate = "2023-01-09"
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
//                let str = String(decoding: safeData, as: UTF8.self)
//                print(str)
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

//let lotte = TheaterLotteManager()
//let cinemaID = "1|1|1013"
//let playDate = "2023-01-10"
//lotte.fetch(cinemaID: cinemaID, playDate: playDate) { theaters in
//    if let theaters = theaters {
//        print(theaters)
//    } else {
//        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
//    }
//}
