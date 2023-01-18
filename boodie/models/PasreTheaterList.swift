//
//  PasreTheaterList.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/10.
//

import UIKit

struct ParseTheaterList{
    
    func parse(_ theater:[TheaterVO]) -> [[String:[TheaterVO]]]{
        var theaterListDictionary: [String:[TheaterVO]] = [:]
        var theaterList:[[String:[TheaterVO]]] = []

        theater.forEach {
            let key = String.removeSpecialCharacter($0.movieName)
            if theaterListDictionary[key] == nil{
                theaterListDictionary[key] = [$0]
            }else{
                theaterListDictionary[key]?.append($0)
            }
        }
        
        theaterListDictionary.forEach {
            theaterList.append([$0.key:$0.value])
        }
//        let intIndex = 0
//        let index = theaterList[0].index(theaterList[0].startIndex, offsetBy: intIndex)
        
        theaterList.sort{
            Array($0.values)[0].count > Array($1.values)[0].count
        }
        for i in 0..<theaterList.count{
            theaterList[i][Array(theaterList[i].keys)[0]] = Array(theaterList[i].values)[0].sorted{
                $0.playStartTime < $1.playStartTime
            }

        }
        
        return theaterList
    }
}
