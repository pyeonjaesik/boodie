//
//  RecoCell.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/14.
//

import UIKit
class RecoCell: UICollectionViewCell {
         
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCell()
    }
    var title = {
        let label = UILabel()
        label.text = "첫 번째 추천"
        label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0.9)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: CGFloat(12))
        return label
    }()
    var subtitle = {
        let label = UILabel()
        label.text = "A01"
        label.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: CGFloat(25))
        return label
    }()

    func setUpCell() {
        contentView.addSubview(self.title)
        contentView.addSubview(self.subtitle)
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,constant: 8).isActive = true
        self.title.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.title.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        self.subtitle.translatesAutoresizingMaskIntoConstraints = false
        self.subtitle.topAnchor.constraint(equalTo: self.title.bottomAnchor,constant: 0).isActive = true
        self.subtitle.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,constant: -8).isActive = true
        self.subtitle.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.subtitle.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true

    }
    
}
