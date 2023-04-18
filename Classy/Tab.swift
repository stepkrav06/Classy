
import Foundation
import SwiftUI

class AppViewModel: ObservableObject {
    @Published var colors = [Color.c1, Color.c2, Color.c5, Color.c3, Color.c4]
    @Published var pickedColor = Color.c1
    @Published var schedule: Schedule = Schedule(schedule: [1:[],2:[],3:[],4:[],5:[],6:[],7:[]])
    @Published var classes: [Class] = []
    @Published var lessons: [Lesson] = []
    @Published var exams: [Exam] = []
    @Published var firstNotificationTime: TimeInterval = 0
    @Published var secondNotificationTime: TimeInterval = 0
    @Published var wantNotifications = false
    @Published var wantSecondNotification = false
    @Published var countdownStartTime = Date()
    @Published var countdownStartClassTime = Date()
    @Published var countdownTimeLength: Double = 0
    @Published var countdownStartTimeExam = Date()
    @Published var countdownStartClassTimeExam = Date()
    @Published var countdownTimeLengthExam: Double = 0
    @Published var countdownStartedForClass: String = ""
    @Published var countdownStartedForExam: String = ""


    @Published var dayPickedForSchedule: String = "Mon"

    let defaults = UserDefaults(suiteName: "group.somePIE.ClassTimer")!

    func timeIntervalToStringTime(interval: TimeInterval) -> String {
        var intervalString = ""
        var roundedInterval = Int(round(interval))



        let hours = (roundedInterval - roundedInterval % 3600)/3600
        roundedInterval = roundedInterval % 3600
        let minutes = (roundedInterval - roundedInterval % 60)/60
        if hours > 0 {
            intervalString += String(hours) + " hour"
        }
        if minutes > 0 && hours > 0 {
            intervalString += " and "
        }
        if minutes > 0 {
            intervalString += String(minutes) + " minutes"
        }
        return intervalString
    }
    func encodeClasses(objects: [Class]){
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(objects)
            defaults.set(data, forKey: "Classes")

        } catch {
            print("Unable to Encode Classes (\(error))")
        }
    }
    func encodeExams(objects: [Exam]){
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(objects)
            defaults.set(data, forKey: "Exams")

        } catch {
            print("Unable to Encode Exams (\(error))")
        }
    }
    
    func encodeSchedule(object: Schedule){
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(object)
            defaults.set(data, forKey: "Schedule")

        } catch {
            print("Unable to Encode Schedule (\(error))")
        }
    }
    
    func removeClass(cl: Class){
        let indClass = classes.firstIndex(of: cl)!
        classes.remove(at: indClass)
        for day in schedule.schedule.keys {
            for lesson in schedule.schedule[day]! {
                if lesson.name == cl.name {
                    let indLesson = schedule.schedule[day]!.firstIndex(of: lesson)!
                    schedule.schedule[day]!.remove(at: indLesson)
                }
            }
        }
        encodeClasses(objects: classes)
        encodeSchedule(object: schedule)
    }
    func removeExam(exam: Exam){
        let indExam = exams.firstIndex(of: exam)!
        exams.remove(at: indExam)

        encodeExams(objects: exams)
    }
}

struct TabItem: Identifiable{
    var id = UUID()
    var text: String
    var icon: String
    var tab: Tab

}
var tabItems = [
    TabItem(text: "Timer", icon: "timer", tab: .timer),
    TabItem(text: "Classes", icon: "list.bullet", tab: .classes),
    TabItem(text: "Settings", icon: "gear", tab: .settings),
]
enum Tab: String {
    case timer
    case classes
    case settings
}


extension Color {
    static let c1 = Color("C1")
    static let c2 = Color("C2")
    static let c3 = Color("C3")
    static let c4 = Color("C4")
    static let c5 = Color("C5")
    static let textC1 = Color("TextC")
    static let darkG = Color("darkG")
}
public let dayToDayNumber = ["Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6, "Sun":7]
public let dayToDayNumberGregorian = ["Mon":2, "Tue":3, "Wed":4, "Thu":5, "Fri":6, "Sat":7, "Sun":1]
public let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
public let daysShort = ["M", "T", "W", "Th", "F", "S", "Su"]
public let stringToTimeInterval: [String: TimeInterval] = ["None":0, "5 min before":60 * 5, "10 min before":60 * 10, "15 min before":60 * 15,"30 min before":60 * 30, "1 hour before":3600,"2 hours before":3600 * 2]
public let timeIntervalToString: [TimeInterval: String] = [0:"None", 60 * 5:"5 min before", 60 * 10:"10 min before", 60 * 15:"15 min before",60 * 30:"30 min before", 3600:"1 hour before",3600 * 2:"2 hours before"]


extension UserDefaults {
  func colorForKey(key: String) -> Color {
    var colorReturnded: UIColor?
    if let colorData = data(forKey: key) {
      do {
          if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
          colorReturnded = color
              
        }
      } catch {
        print("Error UserDefaults")
      }
    }
      return Color(colorReturnded ?? UIColor(Color.c1))
  }

  func setColor(color: UIColor?, forKey key: String) {
    var colorData: NSData?
    if let color = color {
      do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
        colorData = data
      } catch {
        print("Error UserDefaults")
      }
    }
    set(colorData, forKey: key)
  }
}
