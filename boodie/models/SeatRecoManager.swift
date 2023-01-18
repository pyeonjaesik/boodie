//
//  SeatRecoManager.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/14.
//

import Foundation

struct SeatRecoManager{
    
    let seatCGVManager = SeatCGVManager()
    let seatLotteManager = SeatLotteManager()
    let seatMegaManager = SeatMegaManager()
    
    func recommend(_ theaterList:[TheaterVO], completion: @escaping ([TheaterVO]?) -> Void){
        guard !theaterList.isEmpty else{
            completion(nil)
            return
        }
        var fetchCount = 0
        var result:[TheaterVO] = []

        theaterList.forEach { theater in
            var theater = theater
            switch (theater.company){
            case "CGV":
                self.seatCGVManager.fetch(theaterDetail: theater.theaterDetail!) { seats in
                    fetchCount += 1
                    if let seats = seats {
                        if let scores = self.recommend(seats){
                            theater.score = scores[0].score
                            result.append(theater)
                        }
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                    } else {
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                        print("좌석 데이터를 받지 못하였습니다.")
                    }
                }
            case "메가박스":
                self.seatMegaManager.fetch(theaterDetail: theater.theaterDetail!) { seats in
                    fetchCount += 1
                    if let seats = seats {
                        if let scores = self.recommend(seats){
                            theater.score = scores[0].score
                            result.append(theater)
                        }
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                    } else {
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                        print("좌석 데이터를 받지 못하였습니다.")
                    }
                }
            case "롯데시네마":
                self.seatLotteManager.fetch(theaterDetail: theater.theaterDetail!) { seats in
                    fetchCount += 1
                    if let seats = seats {
                        if let scores = self.recommend(seats){
                            theater.score = scores[0].score
                            result.append(theater)
                        }
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                    } else {
                        if fetchCount == theaterList.count{
                            completion(result)
                        }
                        print("좌석 데이터를 받지 못하였습니다.")
                    }
                }
            default:
                break
            }
        }
        
    }
    
    func recommend(_ seats:[SeatVO])->[SeatVO]?{
        var seats = seats
        let userY = 0.6
        let userX = 0.5
        let userP = 0.2
        let userS = 0.6
        
        var minLeft:Double = 10000 , minTop:Double = 10000, maxLeft:Double = 0, maxTop:Double = 0
        let seatWidth = seats[0].width
        let seatHeight = seats[0].height
        
        var index = false
        
        seats.forEach {
            minLeft = min(minLeft,$0.left)
            minTop = min(minTop,$0.top)
            maxLeft = max(maxLeft,$0.left)
            maxTop = max(maxTop,$0.top)
            if $0.available{
                index = true
            }
        }
        
        guard index else{ return nil } // 좌석 없음.
        
        let theaterWidth:Double = maxLeft-minLeft+seatWidth
        let theaterHeight:Double = maxTop-minTop+seatHeight
        
        var result:[SeatVO] = []
        for i in 0..<seats.count{
            var seat = seats[i]
            let cY = ((seat.top-minTop)+(seat.height/2.0))/theaterHeight
            let cX = ((seat.left-minLeft)+(seat.width/2.0))/theaterWidth
            
            var indexY:Double
            let indexX:Double = theaterWidth - abs(userX-cX)*theaterWidth
            
            if cY>userY{
                indexY = 1 - abs(userY-cY)
            }else{
                indexY = 1 - abs(userY-cY)*1.6
            }
            var score = indexX*indexY
            
            if i == 0 || i == seats.count-1{
                seat.score = score
                result.append(seat)
                continue
            }
            
            if seats[i-1].alphabet == seat.alphabet{
                if !seats[i-1].available, seat.left-seats[i-1].left < seatWidth*1.5{
                    // 왼쪽 좌석에 누군가 앉음.
                    if score>0{
                        score *= (1-userS)
                    }else{
                        score *= (1+userS)
                    }

                }
                if seat.left-seats[i-1].left >= seatWidth*1.5{
                    // 왼쪽에 통로가 있음.
                    if score>0{
                        score *= (1+userP)
                    }else{
                        score *= (1-userP)
                    }
                }
            }
            if seat.alphabet == seats[i+1].alphabet{
                if !seats[i+1].available, seats[i+1].left-seat.left < seatWidth*1.5{
                    // 오른쪽 좌석에 누군가 앉음.
                    if score>0{
                        score *= (1-userS)
                    }else{
                        score *= (1+userS)
                    }
                }
                if seats[i+1].left-seat.left >= seatWidth*1.5{
                    if score>0{
                        score *= (1+userP)
                    }else{
                        score *= (1-userP)
                    }
                }
            }
            seat.score = score
            result.append(seat)
        }
        result.sort{
            $0.score! > $1.score!
        }
        let maxScore = result[0].score!
        for i in 0..<result.count{
            result[i].score = (result[i].score!/maxScore)
        }
        
        return result.filter { $0.available }
    }
}
