//
//  TheaterCGVManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

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
//let cgv = TheaterCGVManager()
//cgv.fetch(theaterCd: "0056", playYMD: "20230110") { (theaters) in
//    if let theaters = theaters {
//        print(theaters)
//    } else {
//        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
//    }
//}
