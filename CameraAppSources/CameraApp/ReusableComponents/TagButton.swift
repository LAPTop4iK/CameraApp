//
//  TagButton.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import SnapKit
import UIKit

class TagButton: UIButton {
    var isActiveState: Bool = false {
        didSet {
            toggleButtonState()
        }
    }

    init(title: String) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension TagButton {
    func setup() {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 20
        configuration.baseForegroundColor = .white
        self.configuration = configuration

        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 10

        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)

        snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }

    @objc func touchUpInside() {
        isActiveState.toggle()
    }

    func toggleButtonState() {
        if isActiveState {
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
