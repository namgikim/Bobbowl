//
//  AlbumViewController.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit
import PhotosUI

class AlbumViewController: UIViewController {
    static let storyboardID: String = "AlbumViewController"
    
    // MARK: - Properties
    var bobs: [Bob] = []
    private var numberOfItems: CGFloat = 3
    private var isViewDidLayoutSubviews: Bool = false
    
    enum Mode {
        case view, select
    }
    private var mode: Mode = .view {
        didSet {
            self.settingsSelectionMode()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet var selectBarButtonItem: UIBarButtonItem!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var countTextBarButtonItem: UIBarButtonItem!
    @IBOutlet var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet var actionBarButtonItem: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func touchUpRightBarButtonItem(_ sender: UIBarButtonItem) {
        self.mode = (self.mode == .view ? .select : .view)
    }
    
    @IBAction func touchUpTrashBarButtonItem(_ sender: UIBarButtonItem) {
        self.removeSelectedBobs()
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set TabBarController
        //  TabBarController 의 RootViewController 에 작성해야 할 코드
        //  AppDelegate에서 UITabBarControllerDelegate 를 채택하였음.
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
        // Set NavigationBar
        //  NavigationBar 투명 처리 (컨트롤러 별 적용)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) // 배경이 없는것 같은 효과
//        self.navigationController?.navigationBar.shadowImage = UIImage() // 밑줄 제거
//        self.navigationController?.navigationBar.backgroundColor = .clear // ?
//        self.navigationController?.navigationBar.isTranslucent = true // ?

        // Set albumCollectionView
        self.albumCollectionView.delegate = self
        self.albumCollectionView.dataSource = self
        self.albumCollectionView.allowsMultipleSelection = false // 기본 설정은 false.
        self.setupFlowLayout() // 레이아웃 설정
        self.settingsSelectionMode()
        
        // Set Data
        self.loadBobs() // Load bobs
        
        // Observers
        //  변경사항 전달받음.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveaddBobsNotificationName(_:)),
                                               name: addBobsNotificationName,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.isViewDidLayoutSubviews == false {
            self.albumCollectionView.scrollToItem(at: IndexPath(row: self.bobs.count-1, section: 0),
                                                  at: .bottom, animated: false)
            self.isViewDidLayoutSubviews = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false // 탭 전환시, 사라지는 현상 보완.
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
    
    // MARK: - Methods
    
    /// bobs 를 읽어오기, 없는경우 문구를 표시하는 메소드
    private func loadBobs() {
        self.bobs = BobFileManager.shared.loadBobs(createDate: nil)
        
        let label: UILabel = emptyMessageLabel(text: "등록된 사진이 없어요.",
                                               view: self.albumCollectionView)
        self.albumCollectionView.backgroundView = (self.bobs.count == 0) ? label : nil
    }

    /// cell 레이아웃 설정하는 메소드
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 3 // 아이템 간 최소거리
        flowLayout.minimumLineSpacing = 3 // 행 간 최소거리
        
        let cellSize: CGFloat = (UIScreen.main.bounds.width / self.numberOfItems) - ((flowLayout.minimumInteritemSpacing * (self.numberOfItems - 1)) / self.numberOfItems)
        
        flowLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        // flowLayout.footerReferenceSize = CGSize(width: halfWidth * 3, height: 70)
        // flowLayout.sectionFootersPinToVisibleBounds = true
        self.albumCollectionView.collectionViewLayout = flowLayout
    }
    
    
    /// 변경사항을 전달받았을 때 동작될 메소드
    /// - Parameter noti: 같이 전달받은 정보가 담겨있음.
    @objc private func didReceiveaddBobsNotificationName(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let dataName: String = userInfo[addBobsNotificationInfoKey] as? String else { return }
        
        if dataName == "result" {
            // guard let _: String = userInfo[addBobsNotificationInfoKeyValue] as? String else { return }
            self.reloadCollectionView()
        }
    }
    
    /// collectionView 를 reload에 필요한 코드가 담겨있는 메소드
    private func reloadCollectionView() {
        self.loadBobs()
        self.albumCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    /// mode 값 변경 시, Bar button item 과 선택된 상태를 초기화한다.
    private func settingsSelectionMode() {
        
        self.setCountText() // 초기화 목적.
        
        // bar button item 설정 및 CollectionView 다중선택여부 설정
        switch self.mode {
        case .view:
            self.navigationItem.rightBarButtonItems = [self.selectBarButtonItem]
            self.albumCollectionView.allowsMultipleSelection = false
            self.navigationController?.setToolbarHidden(true, animated: true)
//            self.tabBarController?.tabBar.isHidden = false
            
        case .select:
            self.navigationItem.rightBarButtonItems = [self.cancelBarButtonItem]
            self.albumCollectionView.allowsMultipleSelection = true
            self.navigationController?.setToolbarHidden(false, animated: true)
//            self.tabBarController?.tabBar.isHidden = true
        }
        
        // 선택 초기화
        if let items = self.albumCollectionView.indexPathsForSelectedItems {
            for indexPath in items {
                self.albumCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
    
    /// 선택 바 버튼을 클릭 한 후, 사진을 선택했을 때, 하단 중앙에 개수를 표시하는 메소드
    private func setCountText() {
        
        switch self.mode {
        case .view:
            self.countTextBarButtonItem.title = "항목 선택"
            
        case .select:
            let selectedCount: Int = self.albumCollectionView.indexPathsForSelectedItems?.count ?? 0
            self.countTextBarButtonItem.title = (selectedCount > 0) ? "\(selectedCount)장의 사진이 선택됨" : "항목 선택"
            
            self.trashBarButtonItem.isEnabled = (selectedCount > 0)
            self.actionBarButtonItem.isEnabled = (selectedCount > 0)
        }
    }
    
    private func removeSelectedBobs() {
        guard let selectedBobsIndexPaths: [IndexPath] = self.albumCollectionView.indexPathsForSelectedItems
        else { return }
        
        let alert: UIAlertController = UIAlertController(title: "이 사진이 영구적으로 삭제됩니다.",
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        let action: UIAlertAction = UIAlertAction(title: "\(selectedBobsIndexPaths.count)개의 사진 삭제",
                                                  style: .destructive) { (UIAlertAction) in
            var selectedBobs: [Bob] = []
            for indexPath in selectedBobsIndexPaths {
                selectedBobs.append(self.bobs[indexPath.row])
            }
            print("----------------------------------------------------")
            BobFileManager.shared.removeBobs(bobs: selectedBobs) { (result) in
                if !result { print("LOG: Fail remove bobs..") }
                else {
                    print("LOG: Removed bobs.")
                    
                    self.mode = .view
                    self.reloadCollectionView()
                }
            }
            print("----------------------------------------------------")
        }
        let cancel: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.backgroundColor = .systemGray6 // test
        cell.bob = self.bobs[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension AlbumViewController: AlbumCollectionViewCellDelegate {
    
    /// Cell 을 선택했을 때, self.mode 값에 따라 선택효과를 줄지 결정하고 동작하는 메소드
    /// - Parameter sender: 해당 cell
    func didChangeSelectedValue(_ sender: AlbumCollectionViewCell) {
        
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
