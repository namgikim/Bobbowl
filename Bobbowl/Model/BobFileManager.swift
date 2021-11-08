//
//  BobFileManager.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/03.
//

import UIKit

class BobFileManager {
    static let shared: BobFileManager = BobFileManager()
    
    // MARK: - Properties
    var imageDatas: [ImageData] = []

    var imageDirectoryURL: URL? = {
        
        do {
            let imageDirectoryURL = try FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: false).appendingPathComponent("Images")
            
            if !FileManager.default.fileExists(atPath: imageDirectoryURL.path) {
                try FileManager.default.createDirectory(atPath: imageDirectoryURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            }
            
            return imageDirectoryURL
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }()
    
    let imageDataDirectoryURL: URL? = {
        return try? FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("bobbowl.json")
    }()
    
    init() {
        self.imageDatas = self.loadImageDatas(success: { (result) in
            if let url = self.imageDirectoryURL { print("LOG: url is \(url)") }
            
            if !result { print("LOG: Fail load imageDatas..") }
            else { print("LOG: Loaded ImageDatas.") }
        })
    }
}

extension BobFileManager {

    // MARK: - Methods: Image File Management
    
    /// 이미지 폴더에서 조건에 맞는 사진을 불러오는 메소드
    /// - Parameter createDate: 생성일
    /// - Returns: 사진들
    func loadBobs(createDate: Date?) -> [Bob] {
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return [] }
        
        var result: [Bob] = []
        
        for imageData in self.imageDatas {
            
            // createDate 가 nil인 경우에는 모든 정보를 리턴하고,
            //  nil 이 아닌 경우에는 생성일이 일치하는 정보만 리턴한다.
            if (createDate == nil)
                || (createDate != nil
                        && self.isEqualDate(first: imageData.createDate, second: createDate) == true) {
                
                let imagePath: String = imageDirectoryURL.appendingPathComponent(imageData.name).path
                result.append(Bob(image: UIImage(contentsOfFile: imagePath), imageData: imageData))
            }
        }
        
        return result
    }
    
    func loadBobsForMonth(date: Date) -> [Bob] {
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return [] }
        
        var result: [Bob] = []
        
        for imageData in self.imageDatas {
            
            if self.isEqualMonth(first: imageData.createDate, second: date) == true {
                
                let imagePath: String = imageDirectoryURL.appendingPathComponent(imageData.name).path
                result.append(Bob(image: UIImage(contentsOfFile: imagePath), imageData: imageData))
            }
        }
        
        return result
    }
    
    func loadBobsForCalendar(startDate: Date, endDate: Date) -> [Bob] {
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return [] }
        
        var result: [Bob] = []
        
        for imageData in self.imageDatas {
            
            if self.isInclude(imageData.createDate, start: startDate, end: endDate) {
                
                // if 대표사진만 추가하는 것으로 변경할 예정.
                let imagePath: String = imageDirectoryURL.appendingPathComponent(imageData.name).path
                result.append(Bob(image: UIImage(contentsOfFile: imagePath), imageData: imageData))
            }
        }
        
        return result
    }

    
    /// 사진들을 저장하고, Image Data 까지 저장을 진행하는 메소드
    /// - Parameters:
    ///   - bobs: 사진들
    ///   - success: 성공 혹은 실패에 따라 true/false 로 실행
    func saveBobs(bobs: [Bob], success: @escaping ((Bool) -> Void)) {
        print("LOG: Start save bobs! (count: \(bobs.count))")
        
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else {
            success(false)
            return
        }
        
        if bobs.count == 0 {
            success(false)
            return
        }
        
        var imageDatas: [ImageData] = []
        
        do {
            for bob in bobs {
                imageDatas.append(bob.imageData)
                
                guard let image: UIImage = bob.image,
                      let data: Data = image.jpegData(compressionQuality: 1) else {
                    success(false)
                    return
                }
                
                let imageURL: URL = imageDirectoryURL.appendingPathComponent(bob.imageData.name)
                try data.write(to: imageURL)
            }
            print("LOG: Being saved imageDatas")
            
            var isSuccess: Bool = false
            self.saveImageDatas(willUpdateImageDatas: imageDatas) { (result) in
                isSuccess = result
                if !result { print("LOG: Fail save imageDatas..") }
                else { print("LOG: Saved ImageDatas.") }
            }
            success(isSuccess)
            
        } catch {
            print(error.localizedDescription)
            success(false)
        }
    }
    
    /// 사진들을 삭제하고, Image Data 정보까지 삭제를 진행하는 메소드
    /// - Parameters:
    ///   - bobs: 사진들
    ///   - success: 성공 혹은 실패에 따라 true/false 로 실행
    func removeBobs(bobs: [Bob], success: @escaping ((Bool) -> Void)) {
        print("LOG: Start remove bobs! (count: \(bobs.count))")
        
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else {
            success(false)
            return
        }
        
        var imageDatas: [ImageData] = []
        
        do {
            for bob in bobs {
                imageDatas.append(bob.imageData)
                
                let path: String = imageDirectoryURL.appendingPathComponent(bob.imageData.name).path
                try FileManager.default.removeItem(atPath: path)
            }
            print("LOG: Being removed imageDatas")
            
            var isSuccess: Bool = false
            self.removeImageData(willRemoveImageDatas: imageDatas) { (result) in
                isSuccess = result
                if !result { print("LOG: Fail remove imageDatas..") }
                else { print("LOG: Removed ImageDatas.") }
            }
            
            success(isSuccess)
            
        } catch {
            print(error.localizedDescription)
            success(false)
        }
    }
}

extension BobFileManager {
    
    // MARK: - Methods: Image Data File Management
    /// Image Data 정보가 모여있는 JSON 파일을 읽어오는 메소드
    /// - Returns: Image Data 정보
    private func loadImageDatas(success: @escaping ((Bool) -> Void)) -> [ImageData] {
        guard let imageDataDirectoryURL: URL = self.imageDataDirectoryURL else {
            success(false)
            return []
        }
        
        do {
            let data: Data = try Data(contentsOf: imageDataDirectoryURL)
            let imageDatas: [ImageData] = try JSONDecoder().decode([ImageData].self, from: data)
            
            success(true)
            return imageDatas
        } catch {
            print(error.localizedDescription)
            success(false)
            return []
        }
    }
    
    
    /// 외부에서 Image Data를 변경 후에 다시 불러올 때 사용할 메소드
    func reloadImageDatas() {
        self.imageDatas = self.loadImageDatas(success: { (result) in
            if !result { print("LOG: Fail reload imageDatas..") }
            else { print("LOG: Reload ImageDatas.") }
        })
    }
    
    
    /// Image Data 를 변경 혹은 추가하여 JSON 파일에 저장하는 메소드
    /// - Parameter imageData: 저장 할 Image Data
    func saveImageDatas(willUpdateImageDatas: [ImageData], success: @escaping ((Bool) -> Void)) {
        guard let imageDataDirectoryURL: URL = self.imageDataDirectoryURL else {
            success(false)
            return
        }
        
        if willUpdateImageDatas.count == 0 {
            success(false)
            return
        }
        
        // imageData 의 정보를 변경 혹은 추가
        for imageData in willUpdateImageDatas {
            if let index: Int = self.imageDatas.firstIndex(where: { (data) -> Bool in
                imageData.name == data.name
            }) {
                self.imageDatas.replaceSubrange(index...index, with: [imageData])
            } else {
                self.imageDatas.append(imageData)
            }
        }
        
        // JSON 파일에 저장
        do {
            let data: Data = try JSONEncoder().encode(self.imageDatas)
            try data.write(to: imageDataDirectoryURL)
            
            self.reloadImageDatas() // reload
            
            success(true)
            
        } catch {
            print(error.localizedDescription)
            success(false)
        }
    }
    
    
    /// Image Data 를 제거한 후 JSON 파일에 저장하는 메소드
    /// - Parameter willRemoveImageDatas: 삭제 할 Image Data
    func removeImageData(willRemoveImageDatas: [ImageData], success: @escaping ((Bool) -> Void)) {
        guard let imageDataDirectoryURL: URL = self.imageDataDirectoryURL else {
            success(false)
            return
        }
        
        if willRemoveImageDatas.count == 0 {
            success(false)
            return
        }
        
        // 해당 imageData 삭제
        for imageData in willRemoveImageDatas {
            if let index: Int = self.imageDatas.firstIndex(where: { (data) -> Bool in
                imageData.name == data.name
            }) {
                self.imageDatas.remove(at: index)
            }
        }
        
        // JSON 파일에 저장
        do {
            let data: Data = try JSONEncoder().encode(self.imageDatas)
            try data.write(to: imageDataDirectoryURL)
            
            self.reloadImageDatas() // reload
            
            success(true)
            
        } catch {
            print(error.localizedDescription)
            success(false)
        }
    }
}

extension BobFileManager {
    
    // MARK: - Methods
    private func isEqualDate(first: Date?, second: Date?) -> Bool {
        guard let date1: Date = first else { return false }
        guard let date2: Date = second else { return false }
        
        let date1Year: Int = myCalendar.component(.year, from: date1)
        let date1Month: Int = myCalendar.component(.month, from: date1)
        let date1Day: Int = myCalendar.component(.day, from: date1)
        
        let date2Year: Int = myCalendar.component(.year, from: date2)
        let date2Month: Int = myCalendar.component(.month, from: date2)
        let date2Day: Int = myCalendar.component(.day, from: date2)
        
        if date1Year == date2Year && date1Month == date2Month && date1Day == date2Day {
            return true
        } else {
            return false
        }
    }
    
    private func isEqualMonth(first: Date?, second: Date?) -> Bool {
        guard let date1: Date = first else { return false }
        guard let date2: Date = second else { return false }
        
        let date1Year: Int = myCalendar.component(.year, from: date1)
        let date1Month: Int = myCalendar.component(.month, from: date1)
        
        let date2Year: Int = myCalendar.component(.year, from: date2)
        let date2Month: Int = myCalendar.component(.month, from: date2)
        
        if date1Year == date2Year && date1Month == date2Month {
            return true
        } else {
            return false
        }
    }
    
    private func isInclude(_ date: Date, start: Date, end: Date) -> Bool {
        let standardYear: Int = myCalendar.component(.year, from: date)
        let standardMonth: Int = myCalendar.component(.month, from: date)
        let standard: String = "\(standardYear)\(standardMonth)"
        guard let standardInt: Int = Int(standard) else { return false }
        
        let date1Year: Int = myCalendar.component(.year, from: start)
        let date1Month: Int = myCalendar.component(.month, from: start)
        let date1: String = "\(date1Year)\(date1Month)"
        guard let date1Int: Int = Int(date1) else { return false }
        
        let date2Year: Int = myCalendar.component(.year, from: end)
        let date2Month: Int = myCalendar.component(.month, from: end)
        let date2: String = "\(date2Year)\(date2Month)"
        guard let date2Int: Int = Int(date2) else { return false }
        
        if date1Int <= standardInt, standardInt <= date2Int {
            return true
        } else {
            return false
        }
    }
}
