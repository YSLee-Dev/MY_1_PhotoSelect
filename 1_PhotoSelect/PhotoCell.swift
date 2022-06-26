//
//  PhotoCell.swift
//  1_PhotoSelect
//
//  Created by 이윤수 on 2022/06/23.
//

import UIKit

class PhotoCell : UICollectionViewCell {
    
    let photo : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleToFill
        return img
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.masksToBounds = true
        
        self.contentView.addSubview(self.photo)
        NSLayoutConstraint.activate([
            self.photo.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.photo.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.photo.topAnchor.constraint(equalTo: self.topAnchor),
            self.photo.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
