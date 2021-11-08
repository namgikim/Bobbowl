//
//  PostMainCollectionViewCell.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/08.
//

import UIKit

class PostMainCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = .none
    }
}
