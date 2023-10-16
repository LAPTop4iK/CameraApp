//
//  GalleryViewController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Combine
import UIKit

final class GalleryViewController: AppViewController<GalleryViewModel> {
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var layout: BlocksLayout = {
        let layout = BlocksLayout()
        layout.columnsCount = 2
        layout.delegate = self
        layout.contentPadding = BlocksLayout.Padding(horizontal: 5, vertical: 5)
        layout.cellsPadding = BlocksLayout.Padding(horizontal: 10, vertical: 10)
        return layout
    }()
    
    private let filterButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, image: AppResources.Images.filter, addBackground: true, reversedColors: true)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Alle Bilder"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let bottomBar = BottomBarView()
    
    private lazy var cameraButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, image: AppResources.Images.photo, addBackground: true)
        button.addTarget(self, action: #selector(backToCamera), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, image: AppResources.Images.trash, addBackground: true)
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, image: AppResources.Images.cancel, addBackground: true)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GalleryCollectionViewCell.self)
        setupLayout()
        bindViewModel()
        addLongPressGesture()
    }
}

@objc
private extension GalleryViewController {
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                viewModel?.updateSelection(for: indexPath.item)
            }
        }
    }
        
    func backToCamera() {
        viewModel?.backToCamera()
    }
    
    func deleteTapped() {
        viewModel?.deleteSelectedPhotos()
    }
    
    func cancelTapped() {
        viewModel?.deselectAll()
    }
}
                         
private extension GalleryViewController {
    func bindViewModel() {
        viewModel?.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
            
        viewModel?.$isEditMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleEditModeFor(state)
            }
            .store(in: &cancellables)
    }
    
    func handleEditModeFor(_ isEditing: Bool) {
        filterButton.isHidden = isEditing
        cameraButton.isHidden = isEditing
        
        cancelButton.isHidden = !isEditing
        deleteButton.isHidden = !isEditing
    }
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
    }
            
    func setupLayout() {
        view.addSubview(filterButton)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(cameraButton)
        view.addSubview(bottomBar)
        bottomBar.addButtons(cameraButton, cancelButton, deleteButton)
                
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(filterButton.snp.bottom)
            make.leading.equalToSuperview().offset(20)
        }
                
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
                
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(filterButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
                
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension GalleryViewController: BlocksLayoutDelegate {
    func cellSize(indexPath: IndexPath) -> CGSize {
        guard let imageModel = viewModel?.photos[indexPath.row] else {
            return .zero
        }
        
        let width: CGFloat
        let height: CGFloat
        
        if imageModel.aspectRatio > 1 {
            width = 1.0
            height = 1.0
        } else {
            let moduloValue = indexPath.row % 3
            switch moduloValue {
            case 0:
                width = 9.0
                height = 16.0
            case 1:
                width = 3.0
                height = 4.0
            default:
                width = 1.0
                height = 1.0
            }
        }
        
        let cellWidth = layout.width
        let size = CGSize(width: Int(cellWidth), height: Int((height / width) * cellWidth))
        
        return size
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.photos.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configureWith(model: viewModel?.photos[indexPath.item])
        cell.isSelectionMode = viewModel?.isEditMode ?? false
        
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel?.isEditMode == true {
            viewModel?.updateSelection(for: indexPath.item)
        } else {
            viewModel?.showDetail(for: indexPath)
        }
    }
}
