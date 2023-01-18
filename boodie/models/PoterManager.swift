//
//  TheaterCGVManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/15.
//

import Foundation
import SwiftSoup
import Alamofire

struct LottePoster: Codable {
    let Movie: MoVie
}


// MARK: - Movie
struct MoVie: Codable {
    let PosterURL: String
    let ViewEvaluation: Double
    let BookingRank: String
}

struct PosterManager{
    
    let headers: HTTPHeaders = [
        "Content-type": "multipart/form-data"
    ]
    var movieName = ""
    mutating func fetch(_ theaters:[TheaterVO], completion: @escaping (PosterVO?) -> Void) {
        var param:[String:String]?
        for theater in theaters {
            if theater.company == "메가박스"{
                self.movieName = theater.movieName
                param = [
                    "company":theater.company,
                    "rpstMovieNo":theater.theaterDetail!["rpstMovieNo"]!,
                ]
                break
            }else if theater.company == "롯데시네마"{
                self.movieName = theater.movieName
                param = [
                    "company":theater.company,
                    "RepresentationMovieCode":theater.theaterDetail!["RepresentationMovieCode"]!,
                ]
                break
            }
        }
        guard let paramData = param else{
            completion(nil)
            return
        }
        if paramData["company"]! == "메가박스"{
            performMegaRequest(paramData: paramData) { posterVO in
                completion(posterVO)
            }
        }else{
            
            let param = """
        {"MethodName":"GetMovieDetailTOBE","channelType":"HO","osType":"Chrome","osVersion":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36","multiLanguageID":"KR","representationMovieCode":"\(paramData["RepresentationMovieCode"]!)","memberOnNo":""}
        """
            performLotteRequest(params: ["paramList":param]) { posterVO in
                completion(posterVO)
            }
            
        }
    }

}

//MARK: LOTTE Poster Request
extension PosterManager{
    func performLotteRequest(params: [String: Any], completion: @escaping (PosterVO?) -> Void) {
        let url = "https://www.lottecinema.co.kr/LCWS/Movie/MovieData.aspx"
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
                if let posterVO = self.parseJSON(safeData) {
                    completion(posterVO)
                } else {
                    completion(nil)
                }
            })
    }
    func parseJSON(_ data: Data) ->PosterVO? {
        do {
            let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
            let decodedData = try decoder.decode(LottePoster.self, from: data)
            let poster = decodedData.Movie
            
            let url = URL(string:poster.PosterURL)!
            let imageData = try Data(contentsOf: url)
            return PosterVO(imageData: imageData, movieName: self.movieName, rank: String(poster.BookingRank), rating: String(poster.ViewEvaluation))
            
        } catch {
            assertionFailure("poster Lotte decoding fail")
            print(error)
            return nil
        }
    }
}

//MARK: MEGA Poseter Request
extension PosterManager{
    func performMegaRequest(paramData:[String:String], completion: @escaping (PosterVO?) -> Void) {
        let urlString = "https://www.megabox.co.kr/movie-detail?rpstMovieNo=\(paramData["rpstMovieNo"]!)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
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
            if let posterVO = self.parseDom(safeData) {
                completion(posterVO)
            } else {
                completion(nil)
            }
    }
    task.resume()

    }
    func parseDom(_ data: Data)->PosterVO?{
        do{
            let str = String(decoding: data, as: UTF8.self)
            let doc: Document = try SwiftSoup.parse(str)
            let rating = try doc.select("#contents").select(".score").select(".before").select("em")[0].html()
            
            let imageString = try doc.select(".poster").select("img")[0].attr("src")
            let startIndex = imageString.index(imageString.startIndex, offsetBy: 0)
            let endIndex = imageString.index(imageString.startIndex, offsetBy:imageString.count-7)
            let imageUrl = String(imageString[startIndex ..< endIndex]+"720.jpg")
            let rankElements = try doc.select("#contents").select(".rate").select("em")
            var rank = ""
            if !rankElements.isEmpty{
                rank = try rankElements[0].html()
            }else{
                rank = "-"
            }
            guard let url = URL(string:imageUrl) else {
                return nil
            }
            
            guard let imageData = try? Data(contentsOf: url) else {
                return nil
            }
            return PosterVO(imageData: imageData, movieName: self.movieName, rank: String(rank), rating: rating)
        }catch{
            print(error)
            assertionFailure("poster Mega decoding fail")
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
