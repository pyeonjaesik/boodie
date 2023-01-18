//
//  MovieCell.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/08.
//

import UIKit

class MovieCell:UITableViewCell{
    var theater:TheaterVO?
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var startPlayTime: UILabel!
    @IBOutlet weak var theaterFullName: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var totalSeatCnt: UILabel!
    @IBOutlet weak var restSeatCnt: UILabel!
    @IBOutlet weak var theaterSubtitle: UILabel!
    
}
