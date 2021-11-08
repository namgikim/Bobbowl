//
//  PostCollectionViewCell.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/02.
//

import UIKit

protocol PostCollectionViewCellDelegate {
    func didChangeSelectedValue(_ sender: PostCollectionViewCell)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var delegate: PostCollectionViewCellDelegate?
    override var isSelected: Bool {
        didSet {
            // 값이 바뀔 때마다 PostViewController 에 정의된 메소드가 동작된다. (cell 선택 표시기능)
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
        
        self.imageView.image = UIImage(systemName: "photo")
    }
}

extension PostCollectionViewCell {
    
    // MARK: - Methods
    
    
    private func initializeSelectedView() {
        let x: CGFloat = self.frame.minX
        let y: CGFloat = self.frame.minY
        let width: CGFloat = self.frame.maxY - y // CollectionView Horizontal 이기에 X와 Y를 바꿔서 계산한다?
        let height: CGFloat = self.frame.maxX - x // CollectionView Horizontal 이기에 X와 Y를 바꿔서 계산한다?
        
        // Add 흐린 배경
        let selectedView: UIView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        selectedView.isHidden = true
        selectedView.backgroundColor = .black
        selectedView.alpha = 0.3
        self.addSubview(selectedView)
        self.selectedView = selectedView // hidden 처리 시 사용
        
        // Add 체크 표시
        let checkImageSize: CGFloat = 16
        let checkImageView: UIImageView
        checkImageView = UIImageView(frame: CGRect(x: self.frame.maxY - (checkImageSize * 1.5),
                                                   y: self.frame.maxX - (checkImageSize * 1.5) - (checkImageSize/2),
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
