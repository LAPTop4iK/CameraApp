//
//  CircleButton.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import SnapKit
import UIKit

enum ButtonShape {
    case circle
    case square
    case freeForm
}

class CustomButton: UIButton {
    private let buttonShape: ButtonShape

    init(
        buttonShape: ButtonShape,
        image: UIImage? = nil,
        systemImageName: String? = nil,
        addBackground: Bool = false,
        reversedColors: Bool = false
    ) {
        self.buttonShape = buttonShape
        super.init(frame: .zero)

        if addBackground {
            backgroundColor = reversedColors ? AppResources.Color.peach : .white
        }

        if reversedColors {
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        }

        setContentHuggingPriority(.required, for: .horizontal)

        if let systemImageName = systemImageName {
            configureSystemImage(systemImageName: systemImageName, reversedColors: reversedColors)
        } else {
            setupButton(image: image)
        }
    }

    override init(frame: CGRect) {
        buttonShape = .circle
        super.init(frame: frame)

        setupButton()
    }

    required init?(coder: NSCoder) {
        buttonShape = .circle

        super.init(coder: coder)
        setupButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if buttonShape == .circle {
            layer.cornerRadius = bounds.size.width / 2
        }
    }
}

private extension CustomButton {
    func setupButton(image: UIImage? = nil) {
        imageView?.contentMode = .scaleAspectFit
        setImage(image, for: .normal)

        if buttonShape != .freeForm {
            snp.makeConstraints { make in
                make.width.equalTo(snp.height)
            }
        }
    }

    private func configureSystemImage(systemImageName: String, reversedColors: Bool) {
        guard let color = reversedColors ? .white : AppResources.Color.peach else { return }
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let image = UIImage(systemName: systemImageName, withConfiguration: configuration)?.withTintColor(color, renderingMode: .alwaysOriginal)
        setupButton(image: image)
    }
}
