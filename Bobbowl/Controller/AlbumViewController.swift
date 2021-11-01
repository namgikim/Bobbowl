//
//  AlbumViewController.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit

class AlbumViewController: UIViewController {
    
    // MARK: - Properties
    private var numberOfItems: CGFloat = 3
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        self.setupFlowLayout()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AlbumViewController {
    
    // Methods
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 3 // 아이템 간 최소거리
        flowLayout.minimumLineSpacing = 3 // 행 간 최소거리
        
        let halfWidth: CGFloat = (UIScreen.main.bounds.width / self.numberOfItems) - ((flowLayout.minimumInteritemSpacing * (self.numberOfItems - 1)) / self.numberOfItems)
        
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfWidth)
        // flowLayout.footerReferenceSize = CGSize(width: halfWidth * 3, height: 70)
        // flowLayout.sectionFootersPinToVisibleBounds = true
        self.imageCollectionView.collectionViewLayout = flowLayout
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.backgroundColor = .systemGray6
        
        return cell
    }
}
