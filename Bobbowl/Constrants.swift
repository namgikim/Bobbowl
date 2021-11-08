//
//  Constrants.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/01.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView

// MARK: - Notifications
let addBobsNotificationName: Notification.Name = Notification.Name("addBobsNotificationName")
let addBobsNotificationInfoKey: String = "dataName"
let addBobsNotificationInfoKeyValue: String = "dataValue"

// MARK: - Properties
let myCalendar: Calendar = Calendar.init(identifier: .gregorian)
let myColor1: UIColor = UIColor(red: 240 / 255, green: 202 / 255, blue: 97 / 255, alpha: 1)
let imageCornerRadius: CGFloat = 20.0

// MARK: - Methods
func emptyMessageLabel(text: String, view: UIView) -> UILabel {
    let messageLabel = UILabel(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.frame.size.width,
                                             height: view.frame.size.height))
    messageLabel.text = text
    messageLabel.textColor = .darkGray
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    messageLabel.font = UIFont.systemFont(ofSize: 15.0)
    messageLabel.sizeToFit()

    return messageLabel
}

typealias Indicator1Type = (backgroundView: UIView, view: NVActivityIndicatorView)
func indicator1() -> Indicator1Type {
    let backSize: CGFloat = 90
    let backView: UIView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - backSize,
                                            y: UIScreen.main.bounds.size.height / 2 - backSize,
                                            width: backSize * 2,
                                            height: backSize * 2))
    backView.backgroundColor = .black
    backView.alpha = 0.6 // 투명도
    backView.layer.cornerRadius = 30
    
    let size: CGFloat = 35
    let center: CGRect = CGRect(x: backView.frame.size.width / 2 - size,
                                y: backView.frame.size.height / 2 - size,
                                width: size * 2,
                                height: size * 2)
    let indicator = NVActivityIndicatorView(frame: center,
                                            type: .ballGridBeat,
                                            color: .lightGray,
                                            padding: 0)
    backView.addSubview(indicator)

    return (backgroundView: backView, view: indicator)
}

func myDateComponents(_ date: Date, day: Int?) -> (year: Int, month: Int, day: Int) {
    let year: Int = myCalendar.component(.year, from: date)
    let month: Int = myCalendar.component(.month, from: date)
    let day: Int = (day != nil) ? day! : myCalendar.component(.day, from: date)
    
    return (year: year, month: month, day: day)
}
