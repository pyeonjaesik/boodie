//
//  DetailViewController.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/13.
//

import UIKit



class DetailViewController:UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var goHomepageButton: UIButton!
    
    var theaterVO:TheaterVO?
    var recoCollectionView: RecoCollectionView!
    let seatCGVManager = SeatCGVManager()
    let seatLotteManager = SeatLotteManager()
    let seatMegaManager = SeatMegaManager()
    let seatRecoManager = SeatRecoManager()

    @IBOutlet weak var theaterTitle: UILabel!
    @IBOutlet weak var theaterSubtitle: UILabel!
    
    var frameHeight:Double = 0
    var minLeft:Double = 0, minTop:Double = 10000, maxLeft:Double = 0, maxTop:Double = 0
    var theaterWidth:Double = 0, theaterHeight:Double = 0
    
    var recoSeat:[SeatVO] = []
    var recoTheaterList:[TheaterVO]?
    var resultRecoList:[TheaterVO] = []
    
    var focusedRow = 0
    var score:Double = -1000

    
    var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.frame.size.height = 0
        return view
    }()
    var footer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        view.frame.size.height = 16
        return view
    }()
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        if navigationController!.viewControllers.count == 1{
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
            self.backButton.isHidden = true
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.seatManager()
        self.theaterTitle.text = "\(self.theaterVO!.theaterFullName) - \(self.theaterVO!.playStartTime)"
        self.theaterSubtitle.text = "\(self.theaterVO!.movieName)"
        self.configureGoHomePageButtonUI()
    }
    
    var recoView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var recoLabel = {
        let label = UILabel()
        return label
    }()
    lazy var recoEmptyView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.07)
        view.frame.size.width = self.view.frame.width
        view.frame.size.height = 64
        var label = {
            let label = UILabel()
            label.text = "좌석이 매진되었습니다."
            label.frame.size.width = self.view.frame.width
            label.frame.size.height = 64
            label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
            return label
        }()
        view.addSubview(label)
        return view
    }()
    lazy var recoTheaterTitleView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.frame.size.width = self.view.frame.width
        view.frame.size.height = 48
        return view
    }()
    lazy var recoTheaterTitleLabel = {
        let label = UILabel()
        label.frame.size.width = self.view.frame.width
        label.frame.size.height = 48
        label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        return label
    }()
    

    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func goHomePageButtonTapped(_ sender: Any) {
        switch self.theaterVO!.company{
        case "CGV":
            if let url = URL(string: "http://www.cgv.co.kr/theaters/?areacode=\(self.theaterVO!.theaterDetail!["regionCode"]!)&theaterCode=\(self.theaterVO!.theaterCode)&date=20230116") {
                UIApplication.shared.open(url)
            }
        case "메가박스":
            if let url = URL(string: "https://www.megabox.co.kr/theater?brchNo=\(self.theaterVO!.theaterCode)") {
                UIApplication.shared.open(url)
            }
        case "롯데시네마":

            if let url = URL(string: "https://www.lottecinema.co.kr/NLCHS/Cinema/Detail?divisionCode=1&detailDivisionCode=3&cinemaID=4008") {
                UIApplication.shared.open(url)
            }
        default:
            break
        }

    }
    
}
extension DetailViewController{
    func seatManager(){
        switch (self.theaterVO?.company)!{
        case "CGV":
            seatCGVManager.fetch(theaterDetail: theaterVO!.theaterDetail!) { seats in
                if let seats = seats {
                    self.configureSeatUI(seats)
                } else {
                    assertionFailure("좌석 데이터를 받지 못함.")
                }
            }
        case "메가박스":
            seatMegaManager.fetch(theaterDetail: theaterVO!.theaterDetail!) { seats in
                if let seats = seats {
                    self.configureSeatUI(seats)
                } else {
                    assertionFailure("좌석 데이터를 받지 못함.")
                }
            }
        case "롯데시네마":
            seatLotteManager.fetch(theaterDetail: theaterVO!.theaterDetail!) { seats in
                if let seats = seats {
                    self.configureSeatUI(seats)
                } else {
                    assertionFailure("좌석 데이터를 받지 못함.")
                }
            }
        default:
            break
        }

    }
    func recommendTheater(){
        DispatchQueue.global().async {
            self.configureTheaterTitleUI(3)
            
            if let recoTheaterList = self.recoTheaterList{
                let theaterList = recoTheaterList.filter {
                    if self.theaterVO!.theaterFullName == $0.theaterFullName , self.theaterVO!.playStartTime == $0.playStartTime{
                        return false
                    }else{
                        let time1 = self.theaterVO!.playStartTime.split(separator: ":").map{Int(String($0))!}
                        let time2 = $0.playStartTime.split(separator: ":").map{Int(String($0))!}
                        if abs(time1[0]-time2[0])*60 + abs(time1[1]-time2[1]) < 180{
                            return true
                        }else{
                            return false
                        }
                    }
                }
                self.seatRecoManager.recommend(theaterList){ theater in
                    if let theater = theater, !theater.isEmpty{
                        self.resultRecoList = theater.filter({
                            $0.score! > self.score
                        })
                        self.resultRecoList.sort {
                            $0.playStartTime < $1.playStartTime
                        }
                        if self.resultRecoList.isEmpty{
                            self.configureTheaterTitleUI(0)
                        }else{
                            self.configureTheaterTitleUI(1)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }else{
                        self.configureTheaterTitleUI(2)
                    }
                }
            }
        }
    }
}
extension DetailViewController{
    func configureSeatUI(_ seats:[SeatVO]){
        DispatchQueue.main.async {
            self.tableView.tableHeaderView = self.header
            var minLeft:Double = 10000 , minTop:Double = 10000, maxLeft:Double = 0, maxTop:Double = 0
            seats.forEach {
                minLeft = min(minLeft,$0.left)
                minTop = min(minTop,$0.top)
                maxLeft = max(maxLeft,$0.left)
                maxTop = max(maxTop,$0.top)
            }
            let theaterWidth:Double = maxLeft-minLeft+seats[0].width
            let theaterHeight:Double = maxTop-minTop+seats[0].height
            let frameHeight = self.view.frame.width * (theaterHeight)/(theaterWidth)
            
            self.frameHeight = frameHeight
            self.theaterWidth = theaterWidth
            self.theaterHeight = theaterHeight
            self.minLeft = minLeft
            self.minTop = minTop
            self.maxLeft = maxLeft
            self.maxTop = maxTop
            
            self.header.frame.size.height = frameHeight + 64 + 48
            seats.forEach { seat in
                let component = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.backgroundColor = seat.available ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    view.layer.borderWidth = 0
                    view.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    view.frame.size.width = seat.width * self.view.frame.width/theaterWidth - 2
                    view.frame.size.height = seat.height/theaterHeight * frameHeight - 2
                    view.frame.origin.x = seat.left * (self.view.frame.width/theaterWidth) - minLeft * (self.view.frame.width/theaterWidth) + 1
                    view.frame.origin.y = seat.top * (frameHeight/theaterHeight) - minTop * (frameHeight/theaterHeight) + 1
                    if !seat.available{
                        let image = {
                            let image = UIImageView()
                            image.image = #imageLiteral(resourceName: "x")
                            image.frame.size.width = view.frame.width
                            image.frame.size.height = view.frame.width
                            return image
                        }()
                        view.addSubview(image)
                    }
                    return view
                }()
                if seat.available{
                    let label = {
                        let label = UILabel()
                        label.frame.size.width = seat.width * self.view.frame.width/theaterWidth - 2
                        label.frame.size.height = seat.height/theaterHeight * frameHeight - 2
                        label.text = "\(seat.alphabet)\(seat.no)"
                        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        label.textAlignment = .center
                        label.font = UIFont.systemFont(ofSize: CGFloat((seat.width * self.view.frame.width/theaterWidth - 2)*0.4))
                        return label
                    }()
                    component.addSubview(label)
                }
                self.header.addSubview(component)
            }
            DispatchQueue.global().async {
                self.configureRecoUI(self.seatRecoManager.recommend(seats))
            }
        }
    }
    func configureRecoUI(_ seats:[SeatVO]?){
        DispatchQueue.main.async {
            if let seats = seats{
                self.recommendTheater()
                self.score = seats[0].score!
                self.recommendSeatUI(seats[0])
                for i in 0..<min(10,seats.count){
                    self.recoSeat.append(seats[i])
                }
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                
                self.recoCollectionView = RecoCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
                self.recoCollectionView.translatesAutoresizingMaskIntoConstraints = false
                self.recoCollectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.07)
                self.header.addSubview(self.recoCollectionView)
                self.recoCollectionView.register(RecoCell.classForCoder(), forCellWithReuseIdentifier: "RecoCell")
                self.recoCollectionView.delegate = self
                self.recoCollectionView.dataSource = self
                self.recoCollectionView.frame.size.height = 64
                self.recoCollectionView.frame.size.width = self.view.frame.width
                self.recoCollectionView.frame.origin.x = 0
                self.recoCollectionView.frame.origin.y = self.frameHeight
                self.recoCollectionView.isPagingEnabled = true
                self.recoCollectionView.showsHorizontalScrollIndicator = false
                self.recoCollectionView.reloadData()
            }else{
                self.recommendTheater()
                self.header.addSubview(self.recoEmptyView)
                self.recoEmptyView.frame.origin.x = 0
                self.recoEmptyView.frame.origin.y = self.frameHeight
//                print("좌석이 없음.")
            }
        }
        
    }
    func configureTheaterTitleUI(_ status:Int){
        DispatchQueue.main.async {
            self.recoTheaterTitleView.removeFromSuperview()
            self.recoTheaterTitleLabel.removeFromSuperview()
            self.recoTheaterTitleView.addSubview(self.recoTheaterTitleLabel)
            self.recoTheaterTitleView.frame.origin.y = self.frameHeight + 64
            self.header.addSubview(self.recoTheaterTitleView)
//            self.footer.removeFromSuperview()
            switch status{
            case 0:
                self.recoTheaterTitleLabel.text = "지금 보고 있는 상영관이 제일 좋아요!"
                self.recoTheaterTitleView.frame.size.height = 128
                self.recoTheaterTitleLabel.frame.size.height = 128
                self.recoTheaterTitleLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
                self.footer.frame.size.height = 128-48
            case 1:
                self.recoTheaterTitleLabel.text = "더 좋은 자리에서 볼 수 있어요."
                self.recoTheaterTitleView.frame.size.height = 48
                self.recoTheaterTitleLabel.frame.size.height = 48
                self.recoTheaterTitleLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0.9)
                self.footer.frame.size.height = 16
            case 2:
                self.recoTheaterTitleLabel.text = "추천 상영관이 없습니다."
                self.recoTheaterTitleView.frame.size.height = 128
                self.recoTheaterTitleLabel.frame.size.height = 128
                self.recoTheaterTitleLabel.textColor = #colorLiteral(red: 0.9176470588, green: 0.262745098, blue: 0.2078431373, alpha: 1)
                self.footer.frame.size.height = 128-48
            case 3:
                self.recoTheaterTitleLabel.text = "더 좋은 상영관을 찾고 있어요..."
                self.recoTheaterTitleView.frame.size.height = 64
                self.recoTheaterTitleLabel.frame.size.height = 64
                self.recoTheaterTitleLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
                self.footer.frame.size.height = 64-48
            default:
                break

            }
            self.tableView.tableFooterView = self.footer

        }
    }
    func configureGoHomePageButtonUI(){
        switch self.theaterVO!.company{
        case "CGV":
            self.goHomepageButton.setTitle("CGV 이동", for: .normal)
        case "메가박스":
            self.goHomepageButton.setTitle("메가박스 이동", for: .normal)
        case "롯데시네마":
            self.goHomepageButton.setTitle("롯데시네마 이동", for: .normal)
        default:
            break
        }
    }
}

//MARK: collecitonViewDelegate
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recoSeat.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recoCollectionView.dequeueReusableCell(withReuseIdentifier: "RecoCell", for: indexPath) as! RecoCell
        cell.subtitle.text = "\(self.recoSeat[indexPath.row].alphabet)\(self.recoSeat[indexPath.row].no)"
        let order = ["첫","두","세","네","다섯","여섯","일곱","여덟","아홉","열"]
        cell.title.text = "\(order[indexPath.row]) 번째 추천"
//                cell.memberNameLabel.text = data.memberName[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
}

//MARK: TableViewDelegate
extension DetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return}
        uvc.theaterVO = self.resultRecoList[indexPath.row]
        uvc.recoTheaterList = self.recoTheaterList
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultRecoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TheaterRecoCell") as! TheaterRecoCell
        
        cell.theater = self.resultRecoList[indexPath.row]
        if self.resultRecoList[indexPath.row].theaterFullName.contains("CGV"){
            cell.logo.image = #imageLiteral(resourceName: "logoC")
        }else if self.resultRecoList[indexPath.row].theaterFullName.contains("메가박스"){
            cell.logo.image = #imageLiteral(resourceName: "logoM")
        }else{
            cell.logo.image = #imageLiteral(resourceName: "logoL")
        }
        cell.startPlayTime.text = self.resultRecoList[indexPath.row].playStartTime
        cell.theaterFullName.text = self.resultRecoList[indexPath.row].theaterFullName
        cell.totalSeatCnt.text = "/\(self.resultRecoList[indexPath.row].totalSeatCnt)"
        cell.restSeatCnt.text = "\(self.resultRecoList[indexPath.row].restSeatCnt)"
        cell.theaterSubtitle.text = self.resultRecoList[indexPath.row].theaterSubtitle
        cell.restSeatCnt.textColor = self.resultRecoList[indexPath.row].restSeatCnt == 0 ? #colorLiteral(red: 0.9294117647, green: 0.1098039216, blue: 0.1411764706, alpha: 1) : #colorLiteral(red: 0.1686346531, green: 0.6573652625, blue: 0.2779245675, alpha: 1)
        if self.score == -1000{
            cell.score.text = ""
        }else{
            let score = String(format: "%.1f", ((self.resultRecoList[indexPath.row].score!-self.score)/self.score*100))
            cell.score.text = "+\(score)%"
        }
        if let distance = self.resultRecoList[indexPath.row].distance{
            cell.distance.text = String(distance.prettyDistance)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}


extension DetailViewController{
    func recommendSeatUI(_ seat:SeatVO){
        self.recoView.frame.size.width = seat.width * self.view.frame.width/self.theaterWidth - 2
        self.recoView.frame.size.height = seat.height/self.theaterHeight * self.frameHeight - 2
        self.recoView.frame.origin.x = seat.left * (self.view.frame.width/self.theaterWidth) - self.minLeft * (self.view.frame.width/self.theaterWidth) + 1
        self.recoView.frame.origin.y = seat.top * (self.frameHeight/self.theaterHeight) - self.minTop * (self.frameHeight/self.theaterHeight) + 1
        self.recoView.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.03529411765, blue: 0.3843137255, alpha: 1)
        self.recoLabel.frame.size.width = seat.width * self.view.frame.width/self.theaterWidth - 2
        self.recoLabel.frame.size.height = seat.height/self.theaterHeight * self.frameHeight - 2
        self.recoLabel.text = "\(seat.alphabet)\(seat.no)"
        self.recoLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.recoLabel.textAlignment = .center
        self.recoLabel.font = UIFont.systemFont(ofSize: CGFloat((seat.width * self.view.frame.width/self.theaterWidth - 2)*0.4))
        
        self.recoView.addSubview(recoLabel)
        self.header.addSubview(recoView)
        
    }
}


extension DetailViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.recoCollectionView{
            let scrollIndex =  Int(self.recoCollectionView.bounds.origin.x)%Int(view.frame.width)
            if scrollIndex < 1 || scrollIndex > Int(view.frame.width) - 1{
                let newFocusedRow = Int(round(self.recoCollectionView.bounds.origin.x/view.frame.width))
                if newFocusedRow != self.focusedRow{
                    self.focusedRow = newFocusedRow
//                    let indexPath = IndexPath(row: self.focusedRow, section: 0)
                    recommendSeatUI(self.recoSeat[newFocusedRow])
                }
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.recoCollectionView{
            let newFocusedRow = Int(round(self.recoCollectionView.bounds.origin.x/view.frame.width))
            if newFocusedRow != self.focusedRow{
                self.focusedRow = newFocusedRow
//                let indexPath = IndexPath(row: self.focusedRow, section: 0)
                recommendSeatUI(self.recoSeat[newFocusedRow])
            }
        }
    }
}
