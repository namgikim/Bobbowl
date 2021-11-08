//
//  PostViewController.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit
import MapKit

class PostViewController: UIViewController {
    static let storyboardID: String = "PostViewController"
    
    // MARK: - Properties
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    var standardDate: Date?
    var mainBobs: [Bob] = []
    var subBobs: [Bob] = []
    
    enum Mode {
        case view, select
    }
    private var mode: Mode = .view {
        didSet {
            self.initializeSelection()
        }
    }
    
    private let viewImageCellCount: CGFloat = 5 // Collection View에 한번에 보여질 cell 수
    private let emptyImageCellCount: Int = 2 // 좌우 빈 cell으로 설정할 cell 수
    private var isViewDidLayoutSubviews: Bool = false
    
    // MARK: - IBOutlets
//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var subCollectionView: UICollectionView!
    @IBOutlet var selectBarButtonItem: UIBarButtonItem!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var countTextBarButtonItem: UIBarButtonItem!
    @IBOutlet var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet var actionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - IBActions
    @IBAction func touchUpRightBarButtonItem(_ sender: UIBarButtonItem) {
        self.mode = (self.mode == .view ? .select : .view)
    }
    
    @IBAction func touchUpTrashBarButtonItem(_ sender: UIBarButtonItem) {
        // remove
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set NavigationController
        self.navigationItem.rightBarButtonItems = [self.selectBarButtonItem]
        self.navigationController?.isToolbarHidden = true
        
        // Main Collection View
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.showsHorizontalScrollIndicator = false
        self.mainCollectionView.allowsMultipleSelection = false
//        self.mainCollectionView.register(PostMainCollectionViewCell.self, forCellWithReuseIdentifier: "mainPostCell")
        self.mainCollectionView.isPagingEnabled = true
        self.setupMainCollectionViewFlowLayout()
        
        // Sub Collection View
        self.subCollectionView.delegate = self
        self.subCollectionView.dataSource = self
        self.subCollectionView.showsHorizontalScrollIndicator = false
        self.subCollectionView.allowsMultipleSelection = false // 기본 설정은 false.
//        self.subCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "subPostCell")
        self.setupSubCollectionViewFlowLayout()
        
        // Set Data
        if let date = self.standardDate {
            self.navigationItem.title = self.dateFormatter.string(from: date)
        }
        self.setBobs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.isViewDidLayoutSubviews == false {
//            self.imageView.image = self.bobs[emptyImageCellCount].image
            self.isViewDidLayoutSubviews = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isToolbarHidden = true
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

extension PostViewController {
    
    // MARK: - Methods
    
    /// images의 앞 뒤로 empty 값을 삽입한다.
    private func setBobs() {
        var temp: [Bob] = []
        let emptyImageData = ImageData(name: "empty", createDate: Date(), latitude: nil, longitude: nil)
        
        for _ in 0..<self.emptyImageCellCount {
            temp.append(Bob(image: UIImage(systemName: "photo"), imageData: emptyImageData))
        }
        
        self.mainBobs = BobFileManager.shared.loadBobs(createDate: self.standardDate)
        temp.append(contentsOf: self.mainBobs)
        
        for _ in 0..<self.emptyImageCellCount {
            temp.append(Bob(image: UIImage(systemName: "photo"), imageData: emptyImageData))
        }
        
        self.subBobs = temp
    }
    
    private func setupMainCollectionViewFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let width: CGFloat = self.mainCollectionView.frame.width
        let heigth: CGFloat = self.mainCollectionView.frame.height
        
        flowLayout.itemSize = CGSize(width: width, height: heigth)
        flowLayout.scrollDirection = .horizontal
        
        self.mainCollectionView.collectionViewLayout = flowLayout
    }
    
    private func setupSubCollectionViewFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        // cell간 간격을 제외한 CollectionView의 width를 self.viewImageCellCount 으로 나누어 cell의 width를 정한다.
        let width: CGFloat = (self.subCollectionView.frame.width - (flowLayout.minimumInteritemSpacing * (self.viewImageCellCount-1))) / self.viewImageCellCount
        
        let heigth: CGFloat = self.subCollectionView.frame.height
        
        flowLayout.itemSize = CGSize(width: width, height: heigth)
        flowLayout.scrollDirection = .horizontal
        
        self.subCollectionView.collectionViewLayout = flowLayout
    }
    
    /// CollectionView 가운데 아이템을 가져오기 위한 Point 값
    /// - Returns: 가운데 Point 값
    private func centerPoint(_ collectionView: UICollectionView) -> CGPoint {
        let x: CGFloat = collectionView.contentOffset.x + collectionView.center.x
        let y: CGFloat = 0
        
        // print(self.collectionView.contentOffset.x)
        
        return CGPoint(x: x, y: y)
    }
    
    private func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        var result: Bool = true
        
        if indexPath.row < self.emptyImageCellCount
            || indexPath.row > self.subBobs.count-1 - self.emptyImageCellCount {
            result = false
        }
        
        return result
    }
    
    /// mode 값 변경 시, Bar button item 과 선택된 상태를 초기화한다.
    private func initializeSelection() {
        
        switch self.mode {
        case .view:
            self.navigationItem.rightBarButtonItems = [self.selectBarButtonItem]
            self.subCollectionView.allowsMultipleSelection = false
            
            self.navigationController?.setToolbarHidden(true, animated: true)
            
        case .select:
            self.navigationItem.rightBarButtonItems = [self.cancelBarButtonItem]
            self.subCollectionView.allowsMultipleSelection = true
            
            self.setCountText()
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        
        // 선택 초기화
        if let items = self.subCollectionView.indexPathsForSelectedItems {
            
            for indexPath in items {
                self.subCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
    
    /// 선택 바 버튼을 클릭 한 후, 사진을 선택했을 때, 하단 중앙에 개수를 표시하는 메소드
    private func setCountText() {
        
        switch self.mode {
        case .view:
            self.countTextBarButtonItem.title = "항목 선택"
            
        case .select:
            let selectedCount: Int = self.subCollectionView.indexPathsForSelectedItems?.count ?? 0
            self.countTextBarButtonItem.title = (selectedCount > 0) ? "\(selectedCount)장의 사진이 선택됨" : "항목 선택"
            
            self.trashBarButtonItem.isEnabled = (selectedCount > 0)
            self.actionBarButtonItem.isEnabled = (selectedCount > 0)
        }
    }
    
}

extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.mainCollectionView {
            return self.mainBobs.count
        } else {
            return self.subBobs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.mainCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainPostCell", for: indexPath) as! PostMainCollectionViewCell
            
            cell.imageView.image = self.mainBobs[indexPath.row].image
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subPostCell", for: indexPath) as! PostCollectionViewCell
            
            if self.isValidIndexPath(indexPath) {
                cell.imageView.image = self.subBobs[indexPath.row].image
                
            } else {
                cell.imageView.image = .none
            }
            
            cell.delegate = self
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.mainCollectionView {
            
        } else {
            
            if self.isValidIndexPath(indexPath) {
                
                if self.mode == .view {
                    self.subCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         
        if scrollView == self.mainCollectionView {
             
        } else {
            
            let cgPoint: CGPoint = self.centerPoint(self.subCollectionView)
            
            // 수시로 메인 사진란에 보여주기
            if let indexPath = self.subCollectionView.indexPathForItem(at: cgPoint),
               self.isValidIndexPath(indexPath) == true {
                self.mainCollectionView.selectItem(at: IndexPath(row: indexPath.row - self.emptyImageCellCount,
                                                                 section: 0),
                                                   animated: false,
                                                   scrollPosition: .centeredHorizontally)
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.mainCollectionView {
            let cgPoint: CGPoint = self.centerPoint(self.mainCollectionView)
            
            if let indexPath = self.mainCollectionView.indexPathForItem(at: cgPoint) {
                self.subCollectionView.selectItem(at: IndexPath(row: indexPath.row + self.emptyImageCellCount,
                                                                section: 0),
                                                  animated: false,
                                                  scrollPosition: .centeredHorizontally)
            }
            
        } else {
            let cgPoint: CGPoint = self.centerPoint(self.subCollectionView)
            
            // 스크롤이 감속하여 멈췄을 때, 셀 중앙 이동
            if let indexPath = self.subCollectionView.indexPathForItem(at: cgPoint) {
                if self.isValidIndexPath(indexPath) {
                    self.subCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
            }
        }
    }
}

extension PostViewController: PostCollectionViewCellDelegate {
    
    /// Cell 을 선택했을 때, self.mode 값에 따라 선택효과를 줄지 결정하고 동작하는 메소드
    /// - Parameter sender: 해당 cell
    func didChangeSelectedValue(_ sender: PostCollectionViewCell) {
        
        switch self.mode {
        case .view:
            sender.hiddenSelectedView(true)
        case .select:
            self.setCountText()
            
            if sender.isSelected == true {
                sender.hiddenSelectedView(false)
            } else {
                sender.hiddenSelectedView(true)
            }
        }
    }
}
