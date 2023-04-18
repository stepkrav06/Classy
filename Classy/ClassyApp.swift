//
//  ClassTimerApp.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 10.04.2023.
//

import SwiftUI

import UserNotifications

@main
struct ClassyApp: App {
    @Environment(\.scenePhase) private var phase
    @AppStorage("isDarkMode") private var isDarkMode = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let viewModel = AppViewModel()
    init(){
        viewModel.pickedColor = viewModel.defaults.colorForKey(key: "AccentColor")
        viewModel.wantNotifications = viewModel.defaults.bool(forKey: "wantNotifications")
        viewModel.wantSecondNotification = viewModel.defaults.bool(forKey: "wantSecondNotification")
        viewModel.firstNotificationTime = TimeInterval(viewModel.defaults.float(forKey: "firstNotificationTime"))
        viewModel.secondNotificationTime = TimeInterval(viewModel.defaults.float(forKey: "secondNotificationTime"))
        viewModel.countdownStartTime = viewModel.defaults.value(forKey: "countdownStartTime") as? Date ?? Date()
        viewModel.countdownStartClassTime = viewModel.defaults.value(forKey: "countdownStartClassTime") as? Date ?? Date()
        viewModel.countdownTimeLength = TimeInterval(viewModel.defaults.float(forKey: "countdownTimeLength"))
        viewModel.countdownStartTimeExam = viewModel.defaults.value(forKey: "countdownStartTimeExam") as? Date ?? Date()
        viewModel.countdownStartClassTimeExam = viewModel.defaults.value(forKey: "countdownStartClassTimeExam") as? Date ?? Date()
        viewModel.countdownTimeLengthExam = TimeInterval(viewModel.defaults.float(forKey: "countdownTimeLengthExam"))
        viewModel.countdownStartedForClass = viewModel.defaults.string(forKey: "countdownStartedForClass") ?? ""
        viewModel.countdownStartedForExam = viewModel.defaults.string(forKey: "countdownStartedForExam") ?? ""
        
        

        if let data = viewModel.defaults.data(forKey: "Classes") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let classes = try decoder.decode([Class].self, from: data)
                viewModel.classes = classes

            } catch {
                print("Unable to Decode classes (\(error))")
            }
        }
        if let data = viewModel.defaults.data(forKey: "Exams") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                var exams = try decoder.decode([Exam].self, from: data)

                for exam in exams {
                    if exam.date < Date() {
                        let ind = exams.firstIndex(of: exam)
                        exams.remove(at: ind!)
                    }
                }
                
                    viewModel.encodeExams(objects: exams)

                viewModel.exams = exams

            } catch {
                print("Unable to Decode exams (\(error))")
            }
        }
        if let data = viewModel.defaults.data(forKey: "Schedule") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let schedule = try decoder.decode(Schedule.self, from: data)
                print(schedule)
                viewModel.schedule = schedule
                var lessons: [Lesson] = []
                for day in schedule.schedule.keys {
                    lessons.append(contentsOf: schedule.schedule[day]!)
                }
                viewModel.lessons = lessons


            } catch {
                print("Unable to Decode schedule (\(error))")
            }
        }
    }


    func scheduleNotificationsForWeek() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for cl in viewModel.classes {
            for day in cl.daysTimes.keys {
                let dayNumber = dayToDayNumberGregorian[day]!
                for time in cl.daysTimes[day]! {
                    let startTime = time.components(separatedBy: " - ")[0]
                    // first notification time
                    print("For class \(cl.name):")
                    if viewModel.wantNotifications{
                        var classHour = Int(startTime.components(separatedBy: ":")[0])!
                        var classMin = Int(startTime.components(separatedBy: ":")[1])!
                        if classMin - Int(viewModel.firstNotificationTime) % 3600 / 60 < 0 {
                            classHour = classHour - 1 - Int(viewModel.firstNotificationTime) / 3600 / 60
                            classMin = classMin - Int(viewModel.firstNotificationTime) % 3600 / 60 + 60
                        } else {
                            classHour = classHour - Int(viewModel.firstNotificationTime) / 3600 / 60
                            classMin = classMin - Int(viewModel.firstNotificationTime) % 3600 / 60
                        }
                        var dateInfo = DateComponents()
                        dateInfo.weekday = dayNumber
                        dateInfo.hour = classHour
                        dateInfo.minute = classMin
                        let content = UNMutableNotificationContent()
                        content.title = "\(cl.name) is in \(viewModel.timeIntervalToStringTime(interval: viewModel.firstNotificationTime))"
                        content.subtitle = ""
                        content.sound = UNNotificationSound.default
                        if #available(iOS 15.0, *) {
                                content.interruptionLevel = .timeSensitive
                            }
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request)
                        print("Scheduled for \(dateInfo)")
                    }
                    if viewModel.wantSecondNotification {
                        var classHour = Int(startTime.components(separatedBy: ":")[0])!
                        var classMin = Int(startTime.components(separatedBy: ":")[1])!
                        if classMin - Int(viewModel.secondNotificationTime) % 3600 / 60 < 0 {
                            classHour = classHour - 1 - Int(viewModel.secondNotificationTime) / 3600 / 60
                            classMin = classMin - Int(viewModel.secondNotificationTime) % 3600 / 60 + 60
                        } else {
                            classHour = classHour - Int(viewModel.secondNotificationTime) / 3600 / 60
                            classMin = classMin - Int(viewModel.secondNotificationTime) % 3600 / 60
                        }
                        var dateInfo = DateComponents()
                        dateInfo.weekday = dayNumber
                        dateInfo.hour = classHour
                        dateInfo.minute = classMin
                        let content = UNMutableNotificationContent()
                        content.title = "\(cl.name) is in \(viewModel.timeIntervalToStringTime(interval: viewModel.secondNotificationTime))"
                        content.subtitle = ""
                        content.sound = UNNotificationSound.default
                        if #available(iOS 15.0, *) {
                                content.interruptionLevel = .timeSensitive
                            }
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request)
                        print("Scheduled for \(dateInfo)")
                    }


                }

            }

            

        }






    }

    var body: some Scene {


        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(viewModel)
            
        }
        .onChange(of: phase) { newPhase in
                    switch newPhase {
                    case .background: scheduleNotificationsForWeek()
                    default: break
                    }
                }


    }
}
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase and push messaging configuration

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNs)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        return true
    }

    // function for handling notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }
    // function for handling notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

}

