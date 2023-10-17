//
//  FiltersView.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import SnapKit
import UIKit

class FilterSelectorView: UIView {
    private let allowAddTag: Bool

    var onAddButtonTapped: (() -> Void)?
    var onFilterButtonTapped: ((TagModel, Bool) -> Void)?

    var selectedFilters: [TagModel] {
        var tagButtons: [TagButton] = []
        for subview in mainStackView.arrangedSubviews {
            if let stackView = subview as? UIStackView {
                for button in stackView.arrangedSubviews {
                    if let tagButton = button as? TagButton, tagButton != addButton {
                        if tagButton.isActiveState {
                            tagButtons.append(tagButton)
                        }
                    }
                }
            }
        }
        return tagButtons.map { TagModel(name: $0.title(for: .normal) ?? "") }
    }

    private var initialFilters = true

    private lazy var addButton: TagButton = {
        let button = TagButton(title: "+")
        button.backgroundColor = .white
        button.setTitleColor(AppResources.Color.peach, for: .normal)
        button.tag = 1000
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private let safeView: UIView = {
        let view = UIView()
        return view
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()

    init(allowAddTag: Bool = true) {
        self.allowAddTag = allowAddTag

        super.init(frame: .zero)
        setupViews()
    }

    override init(frame: CGRect) {
        allowAddTag = false

        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup

extension FilterSelectorView {
    private func setupViews() {
        backgroundColor = AppResources.Color.peach
        addSubview(safeView)
        addSubview(mainStackView)

        layer.cornerRadius = 10
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        safeView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(safeView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().inset(10)
        }

        addButton.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
}

// MARK: - Button Actions

extension FilterSelectorView {
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }

    @objc private func filterButtonTapped(_ sender: TagButton) {
        if let title = sender.title(for: .normal) {
            let model = TagModel(name: title)
            onFilterButtonTapped?(model, sender.isActiveState)
        }

        if !allowAddTag {
            deactivateAllButtonsExcept(sender)
        }
    }

    private func deactivateAllButtonsExcept(_ activeButton: TagButton) {
        for subview in mainStackView.arrangedSubviews {
            if let stackView = subview as? UIStackView {
                for button in stackView.arrangedSubviews {
                    if let tagButton = button as? TagButton, tagButton != activeButton {
                        tagButton.isActiveState = false
                    }
                }
            }
        }
        mainStackView.layoutIfNeeded()
    }
}

// MARK: - Filter Methods

extension FilterSelectorView {
    func addFilters(filters: [TagModel], activeTags: [TagModel]) {
        if let addButtonInView = viewWithTag(1000) as? TagButton {
            addButtonInView.removeFromSuperview()
        }

        if initialFilters {
            for filter in filters {
                addFilter(filter, activeTags: activeTags)
            }
            initialFilters = false
        } else {
            addFilter(filters.last, activeTags: activeTags)
        }

        ensureAddButtonIsPresent()
    }

    func addFilter(_ filter: TagModel?, activeTags: [TagModel]) {
        guard let filter = filter else { return }
        let button = TagButton(title: filter.name)
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)

        // Check if the filter is in the activeTags list
        if activeTags.contains(where: { $0.name == filter.name }) {
            button.isActiveState = true
        }

        if let lastRow = mainStackView.arrangedSubviews.last as? UIStackView, canFit(button: button, in: lastRow) {
            lastRow.addArrangedSubview(button)
        } else {
            let newRow = createNewRowStack()
            newRow.addArrangedSubview(button)
            mainStackView.addArrangedSubview(newRow)
        }

        ensureAddButtonIsPresent()
    }

    private func ensureAddButtonIsPresent() {
        guard allowAddTag else { return }
        if let lastRow = mainStackView.arrangedSubviews.last as? UIStackView, canFit(button: addButton, in: lastRow) {
            lastRow.addArrangedSubview(addButton)
        } else {
            let newRow = createNewRowStack()
            newRow.addArrangedSubview(addButton)
            mainStackView.addArrangedSubview(newRow)
        }
    }

    private func createNewRowStack() -> UIStackView {
        let rowStack = UIStackView()
        rowStack.spacing = 4
        rowStack.alignment = .leading
        rowStack.distribution = .fillProportionally
        return rowStack
    }

    private func canFit(button: UIButton, in stackView: UIStackView?) -> Bool {
        guard let stackView else { return false }
        let totalWidth = stackView.arrangedSubviews.reduce(0) { $0 + $1.intrinsicContentSize.width + 8 }
        return (totalWidth + button.intrinsicContentSize.width) <= bounds.width - 32
    }
}
