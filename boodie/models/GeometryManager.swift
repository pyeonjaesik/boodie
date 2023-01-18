//
//  GeometryManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/13.
//

import Foundation

struct Geo: Codable {
    let results: [Result]
}
struct Result: Codable {
    let formatted_address: String
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location

}
struct Location: Codable {
    let lat, lng: Double
}

struct GeometryManager{
    
    var url = "https://maps.googleapis.com/maps/api/geocode/json"

    mutating func fetch(adress:String, completion: @escaping (Double?,Double?,String?) -> Void) {
        self.url += "?address=\(adress)&key=\(geocodingKey)"
        performRequest(to: self.url) { latitude,longitude,adress in
            completion(latitude,longitude,adress)
        }
    }
    func performRequest(to url: String, completion: @escaping (Double?,Double?,String?) -> Void) {
        let encodedStr = self.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodedStr)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
            if error != nil {
                print(error!)
                completion(nil,nil,nil)
                return
            }

            guard let safeData = data else {
                completion(nil,nil,nil)
                return
            }
//            let str = String(decoding: safeData, as: UTF8.self)
//            print(str)
            // 데이터 분석하기
            if let latLongAddress = self.parseJSON(safeData) {
                completion(latLongAddress.0,latLongAddress.1,latLongAddress.2)
            } else {
                completion(nil,nil,nil)
            }
        }
        task.resume()

    }
    func parseJSON(_ data: Data) ->(Double,Double,String)? {
        do {
            let decoder = JSONDecoder() // decode: 데이터를 코드로 변경한다.
            let decodedData = try decoder.decode(Geo.self, from: data)
            guard !decodedData.results.isEmpty else{
                return nil
            }
            let latitude = decodedData.results[0].geometry.location.lat
            let longitude = decodedData.results[0].geometry.location.lng
            let adress = decodedData.results[0].formatted_address
            return (latitude,longitude,adress)
        } catch {
            print(error)
            return nil
        }
    }
}
