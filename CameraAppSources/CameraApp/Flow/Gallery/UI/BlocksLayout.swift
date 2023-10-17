//
//  BlocksLayout.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

protocol BlocksLayoutDelegate: AnyObject {
    func cellSize(indexPath: IndexPath) -> CGSize
}

class BlocksLayout: UICollectionViewLayout {
    struct Padding {
        let horizontal: CGFloat
        let vertical: CGFloat

        init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
            self.horizontal = horizontal
            self.vertical = vertical
        }

        static var zero: Padding {
            return Padding()
        }
    }

    var columnsCount = 5
    var width: CGFloat = 0
    var contentPadding: Padding = .zero
    var cellsPadding: Padding = .zero

    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    var contentSize: CGSize = .zero
    weak var delegate: BlocksLayoutDelegate?

    var contentWidthWithoutPadding: CGFloat {
        return contentSize.width - 2 * contentPadding.horizontal
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func prepare() {
        super.prepare()

        cachedAttributes.removeAll()
        calculateCollectionViewFrames()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }

    func calculateCollectionViewFrames() {
        guard columnsCount > 0 else {
            fatalError("Value must be greater than zero")
        }

        guard let collectionView = collectionView, let delegate = delegate else {
            return
        }

        contentSize.width = collectionView.frame.size.width

        let cellsPaddingWidth = CGFloat(columnsCount - 1) * cellsPadding.vertical
        let cellWidth = (contentWidthWithoutPadding - cellsPaddingWidth) / CGFloat(columnsCount)
        width = cellWidth
        var yOffsets = [CGFloat](repeating: contentPadding.vertical, count: columnsCount)

        for section in 0 ..< collectionView.numberOfSections {
            let itemsCount = collectionView.numberOfItems(inSection: section)

            for item in 0 ..< itemsCount {
                let isLastItem = item == itemsCount - 1
                let indexPath = IndexPath(item: item, section: section)
                let cellHeight = delegate.cellSize(indexPath: indexPath).height

                let cellSize = CGSize(width: cellWidth, height: cellHeight)

                guard let y = yOffsets.min(), let column = yOffsets.firstIndex(of: y) else {
                    continue
                }

                let x = CGFloat(column) * (cellWidth + cellsPadding.horizontal) + contentPadding.horizontal
                let origin = CGPoint(x: x, y: y)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: origin, size: cellSize)
                cachedAttributes.append(attributes)

                yOffsets[column] += cellHeight + cellsPadding.vertical

                if isLastItem, let y = yOffsets.max() {
                    for index in 0 ..< yOffsets.count {
                        yOffsets[index] = y
                    }
                }
            }
        }

        if let maxYOffset = yOffsets.max() {
            contentSize.height = maxYOffset + contentPadding.vertical - cellsPadding.vertical
        }
    }
}
