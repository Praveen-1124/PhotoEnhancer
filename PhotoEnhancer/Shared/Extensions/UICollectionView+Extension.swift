//
//  UICollectionView+Extension.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 11/05/26.
//

import UIKit

extension UICollectionView {

    func register(_ cells: [UICollectionViewCell.Type]) {
        cells.forEach {
            let identifier = String(describing: $0)
            self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        }
    }
}

extension UICollectionViewCell {

    static var rid: String {
        String(describing: Self.self)
    }
}
