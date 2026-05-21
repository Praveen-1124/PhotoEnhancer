//
//  AdjustmentCell.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 11/05/26.
//

import UIKit

class AdjustmentCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()        
        self.setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
    }

    func configure(title: String, icon: String, isSelected: Bool) {

        titleLabel.text = title
        titleLabel.textColor = isSelected ? .systemBackground : .label
        imageView.image = UIImage(systemName: icon)
        imageView.tintColor = isSelected ? .systemBackground : .label
        contentView.backgroundColor = isSelected ? .label : .systemGray6
        contentView.layer.borderColor = (isSelected ? UIColor.systemYellow : UIColor.lightGray).cgColor

        print("AdjustmentCell: \(isSelected)")
    }

}
