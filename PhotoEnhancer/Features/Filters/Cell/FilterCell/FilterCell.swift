//
//  AdjustmentCell.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 11/05/26.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupUI()
    }

    private func setupUI() {
        backgroundImageView.layer.cornerRadius = 16
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
    }

    func configure(title: String, image: UIImage?, isSelected: Bool) {
        titleLabel.text = title
        backgroundImageView.image = image
        titleLabel.textColor = isSelected ? .systemYellow : .label
        contentView.layer.borderColor = (isSelected ? UIColor.systemYellow : UIColor.lightGray).cgColor
    }
}
