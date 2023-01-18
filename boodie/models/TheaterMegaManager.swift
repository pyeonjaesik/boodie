//
//  getMegaTheaterList.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

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
//            let str = String(decoding: safeData, as: UTF8.self)
//            print(str)
            
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

//let theaterMegaManager = TheaterMegaManager()
//theaterMegaManager.fetch(brchNo:"4652", playDe:"20230110") { (theaters) in
//
//    if let theaters = theaters {
//        print(theaters)
//    } else {
//        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
//    }
//}
