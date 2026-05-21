//
//  FeatureButton.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit

class FeatureButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK:  Setup
    private func configure() {

        layer.cornerRadius = 14
        clipsToBounds = true
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18,weight: .semibold)
        backgroundColor = .systemYellow
    }
}
