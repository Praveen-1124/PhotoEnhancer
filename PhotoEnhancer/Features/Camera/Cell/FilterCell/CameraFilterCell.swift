//
//  FilterCell.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit

class CameraFilterCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    private func setupUI() {

        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        layer.cornerRadius = 10
    }

    func configure(with filter: CameraFilter, isSelected: Bool) {

        titleLabel.text = filter.title
        titleLabel.textColor = isSelected ? .black : .white
        backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.25)
    }
}
