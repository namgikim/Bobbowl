//
//  CalendarViewController.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit

class CalendarViewController: UIViewController {
    
    typealias dayArrayType = (year: Int, month: Int, day: Int, isCurrent: Bool, image: UIImage?)
    
    // MARK: - Properties
    var standardDate: Date = Date() // 오늘을 기준으로 동작하며, 스크롤로 날짜를 변경할 때마다 갱신된다.
    let numberOfItems: CGFloat = 7.0
    var totalDayArray: [dayArrayType] = []
    var cellCount: Int = 0
    
    var year: Int = 0
    var month: Int = 0
    
    private var isViewDidLayoutSubviews: Bool = false
    private var selectedDate: (year: Int, month: Int, day: Int)?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set NavigationController
        self.navigationController?.navigationBar.isTranslucent = false

        // Set CalendarCollectionView
        self.calendarCollectionView.delegate = self
        self.calendarCollectionView.dataSource = self
        self.calendarCollectionView.scrollsToTop = false
        self.calendarCollectionView.showsVerticalScrollIndicator = false
        self.calendarCollectionView.allowsMultipleSelection = false
        
        self.setFlowLayout(row: 6)
        
        // Set Data
        self.setDatas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.calendarCollectionView.scrollToItem(at: IndexPath(row: 42, section: 0), at: .top, animated: true)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if self.isViewDidLayoutSubviews == false {
//            self.calendarCollectionView.scrollToItem(at: IndexPath(row: 42, section: 0),
//                                                     at: .top, animated: false)
//            self.isViewDidLayoutSubviews = true
//        }
//    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "calendarToPostSegue" {
            guard let cell = sender as? CalendarCollectionViewCell else { return false }
            
            if cell.imageView.image == .none { return false }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PostViewController {
            let viewController = segue.destination as! PostViewController
            
            guard let cell = sender as? CalendarCollectionViewCell else { return }
            
            viewController.standardDate = myCalendar.date(from: DateComponents(year: cell.year,
                                                                               month: cell.month,
                                                                               day: cell.day))
        }
    }
    
}

extension CalendarViewController {
    
    // MARK: - Methods
    private func setFlowLayout(row: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 0 // 아이템 간 최소거리
        flowLayout.minimumLineSpacing = 0 // 행 간 최소거리
        
        // (UIScreen.main.bounds.width / self.numberOfItems)
        let halfWidth: CGFloat = (self.calendarCollectionView.frame.size.width / self.numberOfItems) - ((flowLayout.minimumInteritemSpacing * (self.numberOfItems - 1)) / self.numberOfItems)
        
        let halfHeight: CGFloat = self.calendarCollectionView.frame.size.height / row
        
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfHeight)
//        flowLayout.footerReferenceSize = CGSize(width: halfWidth * 3, height: 70)
//        flowLayout.sectionFootersPinToVisibleBounds = true
        self.calendarCollectionView.collectionViewLayout = flowLayout
    }
    
    private func setDatas() {
        let yearText: String = String(myCalendar.component(.year, from: self.standardDate))
        let monthText: String = String(myCalendar.component(.month, from: self.standardDate))
        self.dateLabel.text = yearText + ". " + monthText
        
        let prevMonth: Date = myCalendar.date(byAdding: .month, value: -1, to: self.standardDate)!
        let nextMonth: Date = myCalendar.date(byAdding: .month, value:  1, to: self.standardDate)!
        
        self.setTotalDayArray(prevMonth: prevMonth, nextMonth: nextMonth)
    }
    
    /// 이전 달, 현재 달, 다음 달에 대한 배열값을 구하고 종합하여 설정하는 메소드
    private func setTotalDayArray(prevMonth: Date, nextMonth: Date) {
        let prevMonthDayArray: [dayArrayType] = self.getDayArray(date: prevMonth)
        let todayDayArray: [dayArrayType] = self.getDayArray(date: self.standardDate)
        let nextMonthDayArray: [dayArrayType] = self.getDayArray(date: nextMonth)
        
        self.totalDayArray = []
        self.totalDayArray.append(contentsOf: prevMonthDayArray)
        self.totalDayArray.append(contentsOf: todayDayArray)
        self.totalDayArray.append(contentsOf: nextMonthDayArray)
        
        self.cellCount = self.totalDayArray.count
    }
    
    /// 해당 달의 일을 담은 배열을 리턴하느 ㄴ메소드
    /// - Parameter date: 기준일
    /// - Returns: 1~28/29/30/31이 담겨있는 배열
    private func getDayArray(date: Date) -> [dayArrayType] {
        let year: Int = myCalendar.component(.year, from: date)
        let month: Int = myCalendar.component(.month, from: date)
        let date1day: Date = myCalendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        // 기준일의 bobs
        let bobs: [Bob] = BobFileManager.shared.loadBobsForMonth(date: date)
        
        // 1일의 요일 (1~7: 일~토)
        let weekday: Int = myCalendar.component(.weekday, from: date1day)
        
        // 마지막 일
        var dateForLastday: Date
        dateForLastday = myCalendar.date(byAdding: .month, value: 1, to: date1day)!
        dateForLastday = myCalendar.date(byAdding: .day, value: -1, to: dateForLastday)!
        let lastday: Int = myCalendar.component(.day, from: dateForLastday) // 현재 달 마지막 일
        
        // 이전 달의 마지막 일
        var dateForPrevLastday: Date
        dateForPrevLastday = myCalendar.date(byAdding: .day, value: -1, to: date1day)!
        let prevYear: Int = myCalendar.component(.year, from: dateForPrevLastday)
        let prevMonth: Int = myCalendar.component(.month, from: dateForPrevLastday)
        let prevLastday: Int = myCalendar.component(.day, from: dateForPrevLastday) // 이전 달 마지막 일
        
        // 다음 달 정보
        let dateForNextMonth = myCalendar.date(byAdding: .month, value: 1, to: date1day)!
        let nextYear: Int = myCalendar.component(.year, from: dateForNextMonth)
        let nextMonth: Int = myCalendar.component(.month, from: dateForNextMonth)
        
        let currentCellCount: Int = 42
        
        // 현재 달의 시작 요일에 따라 35 혹은 42 형태로 설정
        //  if lastday + (weekday-1) <= 35 { currentCellCount = 35 }
        //  else { currentCellCount = 42 }
        
        // 달력 배열 생성
        var result: [dayArrayType] = []
        var day: Int = 0
        var nextMonthDay: Int = 0
        for i in 1...currentCellCount {
            if i < weekday { // 이전 달 표시
                result.append((year: prevYear, month: prevMonth, day: prevLastday - (weekday-1-i),
                               isCurrent: false, image: nil))
                
            } else if day == lastday { // 다음 달 표시
                nextMonthDay += 1
                result.append((year: nextYear, month: nextMonth, day: nextMonthDay,
                               isCurrent: false, image: nil))
                
            } else { // 현재 달 표시 (메인)
                day += 1
                
                // 계속 비교하지 말고, BobFilemanager에서 31개의 배열을 통으로 내려줘서 빠르게 처리해본다.
                let image: UIImage? = (bobs.first { (bob) -> Bool in
                    return myDateComponents(bob.imageData.createDate, day: nil) == myDateComponents(date, day: day)
                })?.image
                
                result.append((year: year, month: month, day: day,
                               isCurrent: true, image: image))
            }
        }
        
        return result
    }
    
    private func loadBobs(prevMonth: Date, nextMonth: Date) -> [Bob] {
        let bobs = BobFileManager.shared.loadBobsForCalendar(startDate: prevMonth, endDate: nextMonth)
        
        return bobs
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        let dateInfo: dayArrayType = self.totalDayArray[indexPath.row]
        cell.year = dateInfo.year
        cell.month = dateInfo.month
        cell.day = dateInfo.day
        
        cell.dayLabel.text = String(cell.day)
        cell.imageView.image = .none
        
        if self.totalDayArray[indexPath.row].isCurrent == true {
         
            // 글씨 색상
            if (indexPath.row+1) % 7 == 1 { cell.dayLabel.textColor = .systemRed }
            else { cell.dayLabel.textColor = .black }
            
            // 정보
            if dateInfo.image != nil {
                cell.imageView.image = dateInfo.image
            }
            
            // 선택했던 날짜를 기억했다가 다시 표시.
            if let selectedDate = self.selectedDate,
               selectedDate ==  (year: cell.year, month: cell.month, day: cell.day) {
                cell.isSelected = true // deSelect가 동작되지 않아 아래에 별도로 selectITem을 해준다.
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init()) // isSelected가 변경되지 않아 별도로 변경해준다.
            }
            
        } else {
            cell.dayLabel.textColor = .lightGray
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page: Int = Int(scrollView.contentOffset.y) / Int(scrollView.frame.height)
        
        switch page {
        case 0, 2:
            self.standardDate = myCalendar.date(byAdding: .month,
                                                     value: page == 0 ? -1 : 1,
                                                     to: self.standardDate)!
            self.setDatas()
            self.calendarCollectionView.reloadData()
            self.calendarCollectionView.scrollToItem(at: IndexPath(row: 42, section: 0),
                                                     at: .top,
                                                     animated: false)
        case 1:
            return
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        
        self.selectedDate = (year: cell.year, month: cell.month, day: cell.day)
    }
}
