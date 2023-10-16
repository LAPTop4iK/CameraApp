//
//  GalleryViewCell.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit
import SnapKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    private let selectableImageView = SelectableImageView()
    
    var isSelectionMode: Bool = false {
        didSet {
            selectableImageView.isHidden = !isSelectionMode
        }
    }
    
   private var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.selectableImageView.isSelected = false
    }
    
    func configureWith(model: GalleryImageModel?) {
        guard let model else { return }
        imageView.image = model.image
        selectableImageView.isSelected = model.isSelected
    }
}

private extension GalleryCollectionViewCell {
    func setupImageView() {
        contentView.addSubview(imageView)
        imageView.addSubview(selectableImageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectableImageView.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(10)
            make.height.width.equalTo(40)
        }
    }
}
