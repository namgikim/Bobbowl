//
//  AppDelegate.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?
    var addTabViewController: AddTabViewController? // Picker Delegate 에서 사용될 변수
    var tabBarController: UITabBarController? // Picker Delegate 에서 사용될 변수
    
    // MARK: - Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // NavigationBar 투명 처리 (전체 컨트롤러에 적용)
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) // 배경이 없는것 같은 효과
//        UINavigationBar.appearance().shadowImage = UIImage() // 밑줄 제거
//        UINavigationBar.appearance().backgroundColor = .clear
//        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().barTintColor = myColor1
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().tintColor = .black
        UITabBar.appearance().tintColor = .darkGray
        UIToolbar.appearance().tintColor = .darkGray
        
        return true
    }
}


// 게시글 저장 탭 버튼 클릭 시, 탭 이동이 아닌 별도의 동작을 위한 구현부
extension AppDelegate: UITabBarControllerDelegate, PHPickerViewControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // 게시물 추가 탭을 클릭했을 경우, 모달로 띄워준다.
        if viewController is AddTabViewController {
         
            if let viewController = tabBarController.storyboard?.instantiateViewController(withIdentifier: "AddTabViewController") as? AddTabViewController {
                
                // photoPicker select 시 사용될 변수
                self.addTabViewController = viewController
                self.tabBarController = tabBarController
                
                // 사진 권한 체크
                self.authorizationStatus { (result: Bool) in
                    
                    // 권한이 획득되었다면.
                    if result == true {
                        
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "사진 추가",
                                                          message: "사진을 추가할 방식을 선택하세요.",
                                                          preferredStyle: .actionSheet)
                            
                            let camera = UIAlertAction(title: "사진 찍기", style: .default, handler: nil)
                            let album = UIAlertAction(title: "앨범", style: .default, handler: { (UIAlertAction) in
                                
                                let photoPicker = PHPickerViewController(configuration: {
                                    var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                                    config.filter = .images // 사진만 선택할 수 있도록 함.
                                    config.selectionLimit = .max // 다중 선택
                                    
                                    return config
                                }())
                                
                                photoPicker.delegate = self
                                
                                // AppDelegate에서 실행 시, Main Thread에서 실행해야 함.
                                DispatchQueue.main.async {
                                    tabBarController.present(photoPicker, animated: true, completion: nil) }
                            })
                            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                            
                            alert.addAction(camera)
                            alert.addAction(album)
                            alert.addAction(cancel)
                            
                            tabBarController.present(alert, animated: true, completion: nil)
                        }
                        
                    // 권한이 없을 경우.
                    } else {
                        
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "권한 설정",
                                                          message: "[설정 - 사진 접근] 을 허용한 후 진행하세요.",
                                                          preferredStyle: .alert)
                            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
                            
                            alert.addAction(confirm)
                            
                            tabBarController.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
                return false // 별도로 탭 전환은 하지않는다.
            }
            
        }
        
        return true // 정상 실행
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // 현재 열려있는 picker 를 닫아준다.
        picker.dismiss(animated: true, completion: {
            
            if results.count == 0 { return } // 취소 버튼 클릭 시, 0으로 들어오기에 처리함.
            
            // indicator 준비 및 시작
            let indicator = indicator1()
            if let window = self.window {
                window.addSubview(indicator.backgroundView)

                // start
                indicator.view.startAnimating()
            }
            
            // 시간 측정
            let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
            
            // 일정 시간이 소요되어 백그라운드에서 작업.
            OperationQueue().addOperation {
                var bobs: [Bob] = []
                let bobsCount: Int = results.count
                
                for result in results {
                    var newImage: UIImage?
                    let name: String = UUID().uuidString + ".jpeg"
                    var createDate: Date = Date()
                    var latitude: Double?
                    var longitude: Double?

                    // UIImage
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) == true {
                        
                        // itemProvider.loadObject : 비동기 동작;
                        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error: Error?) in
                            
                            if error != nil {
                                print("LOG: Fail load all")
                                print("ERROR: \(error!.localizedDescription)")
                                OperationQueue.main.addOperation {
                                    indicator.view.stopAnimating()
                                    indicator.backgroundView.removeFromSuperview()
                                }
                            }
                            
                            guard let image: UIImage = image as? UIImage else { return }
                            newImage = image
                            
                            // Asset
                            if let assetId = result.assetIdentifier {
                                let assetResults: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                                
                                // print(assetResults.firstObject?.creationDate ?? "No date")
                                // print(assetResults.firstObject?.location?.coordinate ?? "No location")
                                
                                createDate = assetResults.firstObject?.creationDate ?? Date()
                                latitude = assetResults.firstObject?.location?.coordinate.latitude
                                longitude = assetResults.firstObject?.location?.coordinate.longitude
                            }

                            let bob: Bob = Bob(image: newImage,
                                               imageData: ImageData(name: name,
                                                                    createDate: createDate,
                                                                    latitude: latitude,
                                                                    longitude: longitude))
                            bobs.append(bob)
                            
                            // 비동기 동작 완료.
                            if bobsCount == bobs.count {
                                self.saveBobs(bobs: bobs, indicator: indicator, startTime: startTime)
                            }
                        }
                        
                    } else {
                        print("LOG: canLoadObject(ofClass:) is fail")
                    }
                }
            }
        })
    }
}

extension AppDelegate {
    
    // MARK: - Methods
    
    /// 사진 접근 권한 획득 메소드
    /// - Parameter completion: 반환 값이 true일 경우 처리할 메소드
    private func authorizationStatus(completion: @escaping ((Bool) -> Void)) {
        
        let handler: ((PHAuthorizationStatus) -> Void) = { (status) in
            switch status {
            case .authorized:
                print("authorized granted")
                completion(true)
            case .limited:
                print("limited granted")
                completion(true)
            default:
                print("Not granted")
                completion(false)
            }
        }
        
        // 권한 체크 및 notDetermined 시 권한 획득 진행하기.(위 handler 이용)
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            print("status: authorized")
            completion(true)
        case .limited:
            print("status: limited")
            completion(true)
        case .denied:
            print("사용자가 사진 라이브러리에 접근을 거부했습니다.")
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        case .restricted:
            print("앱이 사진 라이브러리에 접근할 수 있는 권한이 없습니다.")
            completion(false)
        @unknown default:
            fatalError()
        }
    }
    
    
    /// bob 정보 저장을 진행하는 메소드
    /// - Parameter bobs: 저장할 사진들
    private func saveBobs (bobs: [Bob], indicator: Indicator1Type, startTime: CFAbsoluteTime) {
        print("----------------------------------------------------")
        if bobs.count != 0 {
            
            BobFileManager.shared.saveBobs(bobs: bobs) { (result) in
                if !result { print("LOG: Fail save bobs..") }
                else { print("LOG: Saved bobs.") }
            }
            
            // 변경사항 전달
            OperationQueue.main.addOperation {
                let userInfo: [String: Any] = [addBobsNotificationInfoKey: "result",
                                               addBobsNotificationInfoKeyValue: true]
                NotificationCenter.default.post(name: addBobsNotificationName,
                                                object: nil,
                                                userInfo: userInfo)
            }
            
            print("LOG: Running time is \(CFAbsoluteTimeGetCurrent() - startTime)s")
            
        } else {
            print("LOG: Bobs count 0")
        }
        print("----------------------------------------------------")
        
        // end
        OperationQueue.main.addOperation {
            indicator.view.stopAnimating()
            indicator.backgroundView.removeFromSuperview()
        }
    }
}
