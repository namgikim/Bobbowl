//
//  AlbumCollectionViewCell.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit

protocol AlbumCollectionViewCellDelegate {
    func didChangeSelectedValue(_ sender: AlbumCollectionViewCell)
}

class AlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var bob: Bob? {
        didSet {
            self.imageView.image = self.bob?.image
        }
    }
    var delegate: AlbumCollectionViewCellDelegate?
    override var isSelected: Bool {
        didSet {
            // 값이 바뀔 때마다 AlbumCollectionViewCell 에 정의된 메소드가 동작된다. (cell 선택 표시기능)
            self.delegate?.didChangeSelectedValue(self)
        }
    }
    var selectedView: UIView?
    var selectedViewCheckImage: UIImageView?
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.contentMode = .scaleAspectFill
        self.initializeSelectedView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.bob = nil
        self.imageView.image = UIImage(systemName: "photo")
    }
}

extension AlbumCollectionViewCell {
    
    // MARK: - Methods
    
    private func initializeSelectedView() {
        let x: CGFloat = self.frame.minX
        let y: CGFloat = self.frame.minY
        let width: CGFloat = self.frame.maxX - x
        let height: CGFloat = self.frame.maxY - y
        
        // Add 흐린 배경
        let selectedView: UIView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        selectedView.isHidden = true
        selectedView.backgroundColor = .black
        selectedView.alpha = 0.3
        self.addSubview(selectedView)
        self.selectedView = selectedView // hidden 처리 시 사용
        
        // Add 체크 표시
        let checkImageSize: CGFloat = 20
        let checkImageView: UIImageView = UIImageView(frame: CGRect(x: self.frame.maxX - (checkImageSize * 2),
                                                                    y: self.frame.maxY - (checkImageSize * 2),
                                                                    width: checkImageSize,
                                                                    height: checkImageSize))
        checkImageView.isHidden = true
        checkImageView.image = UIImage(systemName: "checkmark.square.fill")
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.backgroundColor = .white
        self.addSubview(checkImageView)
        self.selectedViewCheckImage = checkImageView // hidden 처리 시 사용
    }
    
    func hiddenSelectedView(_ isHidden: Bool) {
        self.selectedView?.isHidden = isHidden
        self.selectedViewCheckImage?.isHidden = isHidden
    }
}
