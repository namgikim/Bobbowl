//
//  ImageData.swift
//  Bobbowl
//
//  Created by namgi on 2021/11/02.
//

import Foundation

struct ImageData: Codable {
    var name: String
    var createDate: Date
    var latitude: Double?
    var longitude: Double?
}
