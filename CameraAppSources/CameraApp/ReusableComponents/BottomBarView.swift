//
//  BottomBarView.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

class BottomBarView: UIView {
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppResources.Color.peach
        return view
    }()

    private let safeView: UIView = {
        let view = UIView()
        view.backgroundColor = AppResources.Color.peach
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .equalSpacing
        stack.spacing = 30
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        configureBottomBarView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addButtons(_ buttons: UIButton...) {
        for button in buttons {
            stackView.addArrangedSubview(button)
        }
    }
}

private extension BottomBarView {
    func configureBottomBarView() {
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundColor = AppResources.Color.peach
    }

    func setupViews() {
        addSubview(contentView)
        contentView.addSubview(stackView)
        addSubview(safeView)
    }

    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(108)
            make.bottom.equalTo(safeView.snp.top)
        }

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(24)
        }

        safeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(snp.bottom)
            make.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}
