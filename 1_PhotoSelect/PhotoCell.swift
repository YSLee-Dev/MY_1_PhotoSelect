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
        return img
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.photo)
        NSLayoutConstraint.activate([
            self.photo.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.photo.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.photo.topAnchor.constraint(equalTo: self.topAnchor),
            self.photo.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
