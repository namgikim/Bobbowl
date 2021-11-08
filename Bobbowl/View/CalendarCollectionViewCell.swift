//
//  CalendarCollectionViewCell.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var selectedCircleView: UIView?
    override var isSelected: Bool {
        didSet {
            self.selectedCircleView?.isHidden = !self.isSelected
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.imageView.layer.cornerRadius = 10.0
        
        self.setSelectedCircleView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.year = 0
        self.month = 0
        self.day = 0
        self.dayLabel.text = ""
        self.imageView.image = .none
    }
    
    // MARK: - Methods
    private func setSelectedCircleView() {
        // Set selectedCircleView.
        let center: CGPoint = self.dayLabel.center
        let size: CGFloat = self.dayLabel.frame.height * 0.8
        
        let circleView: UIView = UIView(frame: CGRect(x: center.x - (size/2),
                                                y: center.y - (size/2),
                                                width: size,
                                                height: size))
        circleView.backgroundColor = myColor1
        circleView.layer.cornerRadius = circleView.bounds.size.width * 0.5
        self.insertSubview(circleView, at: self.subviews.count - 1)
        self.selectedCircleView = circleView // hidden 처리 시 사용.
        self.selectedCircleView?.isHidden = true
    }
}
