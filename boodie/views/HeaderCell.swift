//
//  HeaderCell.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/08.
//

import UIKit

class HeaderCell:UICollectionViewCell{
    
    @IBOutlet weak var movieTitle: UILabel!
    override var isSelected: Bool {
        didSet{
            self.movieTitle.textColor = isSelected ? #colorLiteral(red: 0.8235294118, green: 0.03529411765, blue: 0.3843137255, alpha: 1) : .lightGray
        }
    }
    
}
