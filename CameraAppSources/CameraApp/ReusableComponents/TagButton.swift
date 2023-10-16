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
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
}

private extension TagButton {
    func setup() {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 20
        configuration.baseForegroundColor = .white
        self.configuration = configuration
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.layer.cornerRadius = 10
        
        self.addTarget(self, action: #selector(self.touchUpInside), for: .touchUpInside)
        
        snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    @objc func touchUpInside() {
        isActiveState.toggle()
    }
    
    func toggleButtonState() {
        if self.isActiveState {
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            self.layer.borderWidth = 0
        }
    }
}
