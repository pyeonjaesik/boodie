//
//  ViewController.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/08.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var Indicator: UIScrollView!
    @IBOutlet weak var IndicatorContent: UIView!
    @IBOutlet weak var setDateBtn: UIButton!
    @IBOutlet weak var setAdressBtn: UIButton!
    @IBOutlet weak var searchBar: UIView!
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var locationManager:TheaterLocationManager!
    var posterManager = PosterManager()
    
    var posters:[String:PosterVO] = [:]
    
    var focusedRow = 0
    var focusedMovieName:String?
    var startUpdatingLocation = false
    var theaterList:[[String:[TheaterVO]]] = []
    var titleList:[String] = []
    
    let titleMutipleSize = 10
    let titmeMimumSize = 48
    let titlePaddingSize = 28
    let mimumPaddingSize = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInstances()
        configurUI()
        locationManager.fetch(date:0)
        self.searchBar.layer.cornerRadius = 22
    }
    var bar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.03529411765, blue: 0.3843137255, alpha: 1)
        view.frame.size.width = 0
        view.layer.cornerRadius = 6
        view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        return view
    }()
    lazy var theaterListEmptyLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame.size.width = self.view.frame.width
        label.text = "상영 정보가 없네요.\n위치나 날짜를 변경해 주세요!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        label.numberOfLines = 2
        return label
    }()
    
    lazy var requestLocationAthourizationView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "설정에서\n위치 권한을 허용하신 후\n확인 버튼을 클릭해 주세요."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        label.numberOfLines = 3
        return label
    }()
    lazy var requestLocationAthourizationButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("확인", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.frame.size.width = 80
        button.frame.size.height = 56
        button.backgroundColor = #colorLiteral(red: 0.1777858436, green: 0.1777858436, blue: 0.1777858436, alpha: 0.9)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(requestLocationAuthorizedButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func requestLocationAuthorizedButtonTapped(){
        self.locationManager.fetch(date:0)
    }
    @IBAction func setAdressBtnTapped(_ sender: UIButton) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "SetAdressController") else { return}
        uvc.modalTransitionStyle = .coverVertical
        self.present(uvc,animated:true)
    }
    @IBAction func setDateBtnTapped(_ sender: UIButton) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "SetDateController") else { return}
//        uvc.modalPresentationStyle = .fullScreen

        uvc.modalTransitionStyle = .coverVertical
        self.present(uvc,animated:true)
    }
    
    
}
//MARK: CollectionViewDelegate
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.theaterList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCell
            cell.theaterList = Array(self.theaterList[indexPath.row].values)[0]
            cell.posterVO = nil
            cell.tableView.reloadData()
            
            cell.presentDetailView = { [weak self] (theaterVO) in
                guard let uvc = self?.storyboard?.instantiateViewController(withIdentifier: "DetailNavigationController") as? DetailNavigationController else { return }
                uvc.modalTransitionStyle = .coverVertical
                uvc.setNavigationBarHidden(false, animated: true)
                let detailViewController = uvc.viewControllers.first as? DetailViewController
                detailViewController!.theaterVO = theaterVO
                detailViewController!.recoTheaterList = Array(self!.theaterList[indexPath.row].values)[0]
                self?.present(uvc,animated:true)
            }
            cell.row = indexPath.row
            if self.posters[Array(self.theaterList[indexPath.row].keys)[0]] == nil{
                self.posterManager.fetch(Array(self.theaterList[indexPath.row].values)[0]) { posterVO in
                    if let posterVO = posterVO{
                        cell.posterVO = posterVO
                        self.posters[Array(self.theaterList[indexPath.row].keys)[0]] = posterVO
                    }else{
                        cell.posterVO = nil
                        print("롯데 시네마 /메가 박스 상영시간표가 없어 poster없음.",Array(self.theaterList[indexPath.row].values)[0])
                    }
                }
            }else{
                cell.posterVO = self.posters[Array(self.theaterList[indexPath.row].keys)[0]]
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.movieTitle.text = self.titleList[indexPath.row]
//            cell.layer.borderWidth = 1
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerCollectionView{
            self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollectionView{
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
        }else{
            let width = self.titleList[indexPath.row].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[indexPath.row].count*self.titleMutipleSize+self.titlePaddingSize
            return CGSize(width: width, height: 50)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }

}

//MARK: Handling Scroll
extension ViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainCollectionView{
            let leftRow = Int(self.mainCollectionView.bounds.origin.x/view.frame.width)
            let rightRow = Int(ceil(self.mainCollectionView.bounds.origin.x/view.frame.width))
            let leftTitleWidth = self.titleList[leftRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[leftRow].count*self.titleMutipleSize+self.titlePaddingSize
            let rightTitleWidth = self.titleList[rightRow].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[rightRow].count*self.titleMutipleSize+self.titlePaddingSize
            
            
            var totalWidth = 0
            for i in 0..<leftRow{
                let textWidth = self.titleList[i].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[i].count*self.titleMutipleSize+self.titlePaddingSize
                totalWidth += textWidth
            }
            self.bar.frame.origin.x = CGFloat(totalWidth) + (self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width))*CGFloat(leftTitleWidth)/view.frame.width
            
            
            let transition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            if transition.x < 0{
                self.bar.frame.size.width = CGFloat(leftTitleWidth) + CGFloat(rightTitleWidth-leftTitleWidth)*self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width)/view.frame.width
            }else{
                self.bar.frame.size.width = CGFloat(rightTitleWidth) + CGFloat(leftTitleWidth-rightTitleWidth)*(1.0-self.mainCollectionView.bounds.origin.x.truncatingRemainder(dividingBy: view.frame.width)/view.frame.width)
            }
            
            
            let scrollIndex =  Int(self.mainCollectionView.bounds.origin.x)%Int(view.frame.width)
            if scrollIndex < 1 || scrollIndex > Int(view.frame.width) - 1{
                let newFocusedRow = Int(round(self.mainCollectionView.bounds.origin.x/view.frame.width))
                if newFocusedRow != self.focusedRow{
                    self.focusedRow = newFocusedRow
                    self.focusedMovieName = Array(self.theaterList[newFocusedRow].keys)[0]
                    let indexPath = IndexPath(row: self.focusedRow, section: 0)
                    self.headerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
//                UIView.animate(withDuration: 0.12) {
//                    //self.bar.frame.origin.x = 100*CGFloat(self.focusedRow)
//                    self.bar.frame.size.width = CGFloat(titleWidth)
//
//                }
//                UIView.animate(withDuration: 3) {
//                }
            }
        }else if scrollView == self.headerCollectionView{
            self.Indicator.bounds.origin.x = self.headerCollectionView.bounds.origin.x
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.mainCollectionView{
            let newFocusedRow = Int(round(self.mainCollectionView.bounds.origin.x/view.frame.width))
            if newFocusedRow != self.focusedRow{
                self.focusedRow = newFocusedRow
                self.focusedMovieName = Array(self.theaterList[newFocusedRow].keys)[0]
                let indexPath = IndexPath(row: self.focusedRow, section: 0)
                self.headerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
}

//MARK: TheaterLocationManagerDelegate : 상영관 리스트를 받아옴.
extension ViewController:TheaterLocationManagerDelegate{
    func theaterLocationManager(dateString: String, adressString: String) {
        self.theaterListEmptyLabel.removeFromSuperview()
        self.requestLocationAthourizationButton.removeFromSuperview()
        self.requestLocationAthourizationView.removeFromSuperview()
        
        self.setDateBtn.setTitle(" \(dateString)", for: .normal)
        self.setAdressBtn.setTitle(" \(adressString)", for: .normal)
        if dateString.contains("오늘"){
            self.setDateBtn.setTitleColor(#colorLiteral(red: 0.07450980392, green: 0.6470588235, blue: 0.2196078431, alpha: 1), for: .normal)
        }
  
    }
    func theaterLocationManager(_ theater: [TheaterVO]?) {
        if let theater = theater{
            if theater.isEmpty{
                // 상영 정보가 없음.
                DispatchQueue.main.async {
                    self.view.addSubview(self.theaterListEmptyLabel)
                    self.theaterListEmptyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                    self.theaterListEmptyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                }
            }else{
                self.theaterList = ParseTheaterList().parse(theater)
                self.titleList = self.theaterList.map{
                    Array($0.values)[0][0].movieName
                }
                self.fetchSecondPoster()
                self.configureCollectionView()
            }
        }else{
            DispatchQueue.main.async {
                self.view.addSubview(self.requestLocationAthourizationView)
                self.requestLocationAthourizationView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                self.requestLocationAthourizationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                
                self.view.addSubview(self.requestLocationAthourizationButton)
                self.requestLocationAthourizationButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                self.requestLocationAthourizationButton.topAnchor.constraint(equalTo: self.requestLocationAthourizationView.bottomAnchor, constant: 32).isActive = true
                self.requestLocationAthourizationButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
                self.requestLocationAthourizationButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
            }
            
            print("위치 권한을 허용해 주세요.")
        }
    }
}

//MARK: configure UI & intialize Delegate
extension ViewController{
    func initializeInstances(){
        self.locationManager = TheaterLocationManager.shared
        self.locationManager.delegate = self
    }
    func configurUI(){
        let indexPath = IndexPath(item: self.focusedRow, section: 0)
        headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        self.Indicator.addSubview(bar)
        bar.frame.size.height = self.IndicatorContent.frame.height
    }
    func configureCollectionView(){
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
            self.headerCollectionView.reloadData()
//            print(self.focusedMovieName)
            self.focusedRow = 0
            if self.focusedMovieName != nil{
                for i in 0..<self.theaterList.count{
                    if Array(self.theaterList[i].keys)[0] == self.focusedMovieName!{
                        self.focusedRow = i
                        break
                    }
                }
            }

            let indexPath = IndexPath(row: self.focusedRow, section: 0)
            self.headerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.headerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            if self.theaterList.count > 0 {
                self.bar.frame.size.width = self.titleList[self.focusedRow].count*self.titleMutipleSize <= self.titmeMimumSize ? CGFloat(self.titmeMimumSize+self.mimumPaddingSize) : CGFloat(self.titleList[self.focusedRow].count*self.titleMutipleSize+self.titlePaddingSize)
                
                var totalWidth = 0
                for i in 0..<self.focusedRow{
                    let textWidth = self.titleList[i].count*self.titleMutipleSize <= self.titmeMimumSize ? self.titmeMimumSize+self.mimumPaddingSize : self.titleList[i].count*self.titleMutipleSize+self.titlePaddingSize
                    totalWidth += textWidth
                }
                self.bar.frame.origin.x = CGFloat(totalWidth)
            }
        }
    }
}
extension ViewController{
    func fetchAllPoster(){
        // 모든 포스터를 미리 다운로드 받아, 잘못된 포스터가 화면에 표시되는 것을 방지합니다.
        DispatchQueue.global().async {
            self.theaterList.forEach{
                let key = Array($0.keys)[0]
                let value = Array($0.values)[0]
                if self.posters[key] == nil{
                    self.posterManager.fetch(value) { posterVO in
                        if let posterVO = posterVO{
                            self.posters[key] = posterVO
                        }else{
                            print("롯데 시네마 /메가 박스 상영시간표가 없어 poster가 없거나,  오류가 발생함.")
                        }
                    }
                }
            }
        }
    }
    func fetchSecondPoster(){
        // 두 번째 컬렉션 뷰의 포스터가 늦게 로딩되어 호출하는 함수입니다.
        DispatchQueue.global().async {
            
            if self.theaterList.count >= 1{
                let key = Array(self.theaterList[1].keys)[0]
                let value = Array(self.theaterList[1].values)[0]
                self.posterManager.fetch(value) { posterVO in
                    if let posterVO = posterVO{
                        self.posters[key] = posterVO
                    }else{
                        print("롯데 시네마 /메가 박스 상영시간표가 없어 poster가 없거나,  오류가 발생함.")
                    }
                    self.fetchAllPoster()
                }
            }
        }
    }
}
