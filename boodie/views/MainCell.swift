//
//  MainCell.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/08.
//

import UIKit

class MainCell: UICollectionViewCell{
    @IBOutlet weak var tableView: UITableView!
    var theaterList:[TheaterVO] = []
    var presentDetailView:(TheaterVO)->Void = {_ in }
    var posterVO:PosterVO?{
        didSet{
            self.configureHeaderUI()
        }
    }
    var row:Int?
    
    var footer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        view.frame.size.height = 16
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.tableFooterView = self.footer

    }

    func configureHeaderUI(){
        DispatchQueue.main.async {
            if let posterVO = self.posterVO{
                var containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
//                containerView.addSubview(self.header)
                self.tableView.tableHeaderView = containerView

                containerView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
                containerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
                containerView.heightAnchor.constraint(equalToConstant: self.tableView.frame.width*0.27*1.4375*1.28).isActive = true
                containerView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
                containerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                var backgroundImage:UIImageView = {
                    let image = UIImageView()
                    image.translatesAutoresizingMaskIntoConstraints = false
                    return image
                }()
                backgroundImage.image = UIImage(data: posterVO.imageData)
                containerView.addSubview(backgroundImage)
                backgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
                backgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
                backgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
                backgroundImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true

                var visualEffectView = {
                    let blurEffect = UIBlurEffect(style: .dark)
                    let view = UIVisualEffectView(effect: blurEffect)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
                }()
                
                containerView.addSubview(visualEffectView)
                visualEffectView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
                visualEffectView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
                visualEffectView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
                visualEffectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
                
                var bottomView: UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    view.layer.cornerRadius = 18
                    view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
                    return view
                }()
                
                containerView.addSubview(bottomView)
                bottomView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
//                bottomView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
                bottomView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
                bottomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
                bottomView.heightAnchor.constraint(equalToConstant: 36).isActive = true
                
                var posterImage:UIImageView = {
                    let image = UIImageView()
                    image.translatesAutoresizingMaskIntoConstraints = false
                    return image
                }()
                posterImage.image = UIImage(data: posterVO.imageData)
                containerView.addSubview(posterImage)
                posterImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: self.tableView.frame.width*(-0.1)).isActive = true
                posterImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: self.tableView.frame.width*0.27*1.4375*0.17).isActive = true
                posterImage.widthAnchor.constraint(equalToConstant: self.tableView.frame.width*0.27).isActive = true
                posterImage.heightAnchor.constraint(equalToConstant: self.tableView.frame.width*0.27*1.4375).isActive = true

                var movieLabel = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    label.font = UIFont.boldSystemFont(ofSize: CGFloat(21))
                    return label
                }()
                containerView.addSubview(movieLabel)
                movieLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: self.tableView.frame.width*0.07).isActive = true
                movieLabel.trailingAnchor.constraint(equalTo: posterImage.leadingAnchor, constant: self.tableView.frame.width*(-0.07)).isActive = true
                movieLabel.topAnchor.constraint(equalTo: posterImage.topAnchor, constant: self.tableView.frame.width*0.27*1.4375*0.03).isActive = true
                movieLabel.text = posterVO.movieName
                movieLabel.numberOfLines = 2
                
                
                let ratingTitle = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    label.font = UIFont.boldSystemFont(ofSize: CGFloat(13))
                    label.text = "평       점"
                    return label
                }()
                containerView.addSubview(ratingTitle)
                ratingTitle.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 8).isActive = true
                ratingTitle.leadingAnchor.constraint(equalTo: movieLabel.leadingAnchor, constant: 0).isActive = true
                
                
                let rankingTitle = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    label.font = UIFont.boldSystemFont(ofSize: CGFloat(13))
                    label.text = "예매순위"
                    return label
                }()
                containerView.addSubview(rankingTitle)
                rankingTitle.topAnchor.constraint(equalTo: ratingTitle.bottomAnchor, constant: 8).isActive = true
                rankingTitle.leadingAnchor.constraint(equalTo: ratingTitle.leadingAnchor, constant: 0).isActive = true
                
                let rating = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    label.font = UIFont.boldSystemFont(ofSize: CGFloat(18))
                    return label
                }()
                containerView.addSubview(rating)
                rating.firstBaselineAnchor.constraint(equalTo: ratingTitle.firstBaselineAnchor, constant: 0).isActive = true
                rating.leadingAnchor.constraint(equalTo: ratingTitle.trailingAnchor, constant: 10).isActive = true
                rating.text = posterVO.rating
                
                let ranking = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = #colorLiteral(red: 0.9921568627, green: 0.3607843137, blue: 0.3882352941, alpha: 1)
                    label.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
                    return label
                }()
                containerView.addSubview(ranking)
                ranking.firstBaselineAnchor.constraint(equalTo: rankingTitle.firstBaselineAnchor, constant: 0).isActive = true
                ranking.leadingAnchor.constraint(equalTo: rating.leadingAnchor, constant: 0).isActive = true
                ranking.text = "\(posterVO.rank)위"
                
                self.tableView.tableHeaderView?.layoutIfNeeded()
                self.tableView.tableHeaderView = self.tableView.tableHeaderView
                
                let goPosterPageButton = {
                    let button = UIButton()
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    button.addTarget(self, action: #selector(self.goPosterPageButtonTapped), for: .touchUpInside)
                    return button
                }()
                containerView.addSubview(goPosterPageButton)
                goPosterPageButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
                goPosterPageButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
                goPosterPageButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
                goPosterPageButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
            }else{
                
            }
        }
    }
    @objc func goPosterPageButtonTapped(){
        var theaterVO:TheaterVO?
        for i in 0..<self.theaterList.count{
            if self.theaterList[i].company == "롯데시네마" || self.theaterList[i].company == "메가박스"{
                theaterVO = self.theaterList[i]
                break
            }
        }
        guard let theater = theaterVO else{
            return
        }

        if theater.company == "롯데시네마"{
            print(theater)
            if let url = URL(string: "https://www.lottecinema.co.kr/NLCMW/Movie/MovieDetailView?movie=\(theater.theaterDetail!["RepresentationMovieCode"]!)") {
                UIApplication.shared.open(url)
            }
        }else if theater.company == "메가박스"{
            if let url = URL(string: "https://www.megabox.co.kr/movie-detail?rpstMovieNo=\(theater.theaterDetail!["rpstMovieNo"]!)") {
                UIApplication.shared.open(url)
            }
        }

    }
}

extension MainCell: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentDetailView(self.theaterList[indexPath.row])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.theaterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        cell.theater = self.theaterList[indexPath.row]
        if self.theaterList[indexPath.row].theaterFullName.contains("CGV"){
            cell.logo.image = #imageLiteral(resourceName: "logoC")
        }else if self.theaterList[indexPath.row].theaterFullName.contains("메가박스"){
            cell.logo.image = #imageLiteral(resourceName: "logoM")
        }else{
            cell.logo.image = #imageLiteral(resourceName: "logoL")
        }
        cell.startPlayTime.text = self.theaterList[indexPath.row].playStartTime
        cell.theaterFullName.text = self.theaterList[indexPath.row].theaterFullName
        cell.totalSeatCnt.text = "/\(self.theaterList[indexPath.row].totalSeatCnt)"
        cell.restSeatCnt.text = "\(self.theaterList[indexPath.row].restSeatCnt)"
        cell.theaterSubtitle.text = self.theaterList[indexPath.row].theaterSubtitle
        cell.restSeatCnt.textColor = self.theaterList[indexPath.row].restSeatCnt == 0 ? #colorLiteral(red: 0.9294117647, green: 0.1098039216, blue: 0.1411764706, alpha: 1) : #colorLiteral(red: 0.1686346531, green: 0.6573652625, blue: 0.2779245675, alpha: 1)
        
        if let distance = self.theaterList[indexPath.row].distance{
            cell.distance.text = String(distance.prettyDistance)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}
