//
//  Class.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 10.04.2023.
//

import Foundation
import SwiftUI

struct Class: Identifiable, Equatable, Codable, Hashable {

    public var id = UUID()
    var name: String
    var daysTimes: [String:[String]]
    var description: String
    var colorR: Double
    var colorG: Double
    var colorB: Double
    var colorA: Double
    var location: String
    

    
}
struct Lesson: Identifiable, Equatable, Codable, Hashable {
    public var id = UUID()
    var name: String
    var timeStart: String
    var timeEnd: String
    var colorR: Double
    var colorG: Double
    var colorB: Double
    var colorA: Double


}
struct Schedule: Identifiable, Equatable, Codable, Hashable {
    public var id = UUID()
    var schedule: [Int:[Lesson]]
}
struct Exam: Identifiable, Equatable, Codable, Hashable {
    public var id = UUID()
    var name: String
    var cl: Class
    var date: Date
    var dateString: String
}


