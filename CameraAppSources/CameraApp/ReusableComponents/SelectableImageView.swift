//
//  SelectableImageView.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import SnapKit
import UIKit

class SelectableImageView: UIView {
    private let stateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var isSelected: Bool = false {
        didSet {
            updateState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.size.width / 2
    }
}

private extension SelectableImageView {
    func setupView() {
        addSubview(stateImageView)

        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor

        stateImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateState()
    }

    func updateState() {
        if isSelected {
            stateImageView.tintColor = AppResources.Color.red
            stateImageView.image = AppResources.Images.tick
            backgroundColor = .white
        } else {
            stateImageView.tintColor = UIColor.white
            stateImageView.image = nil
            backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
    }
}
