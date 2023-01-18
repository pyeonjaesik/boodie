//
//  TheaterVO.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/09.
//

import Foundation
struct TheaterVO: Codable {
    let company: String
    var theaterCode: String
    let theaterName: String // 서버에서 가져온 상영관 이름
    let theaterSubtitle: String
    let theaterStyle: String
    let theaterStyleSubtitle: String? //조조
    let playStartTime, playEndTime: String
    let movieName, movieNo: String
    let restSeatCnt, totalSeatCnt: Int
    
    var theaterFullName: String = "" //로컬에서 가져온 상영관 이름
    var distance:Double?
    var theaterDetail:[String:String]?
    var score:Double?
}
