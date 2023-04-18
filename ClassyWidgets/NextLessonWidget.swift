//
//  NextLessonWidget.swift
//  ScheduleDayWidgetExtension
//
//  Created by Степан Кравцов on 18.04.2023.
//

import Foundation
import WidgetKit
import SwiftUI

struct NextLessonWidgetContent: TimelineEntry {
    var date = Date()
    let lesson: Lesson
    let nextDate: Date
}





let nextLessonSnapshotEntry = NextLessonWidgetContent(lesson: Lesson(name: "Class", timeStart: "10:00", timeEnd: "11:00", colorR: 0, colorG: 0.7, colorB: 0.7, colorA: 1), nextDate: Date(timeIntervalSinceNow: 60 * 10))

struct NextLessonProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextLessonWidgetContent {
        nextLessonSnapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (NextLessonWidgetContent) -> ()) {
        let defaults = UserDefaults(suiteName: "group.somePIE.ClassTimer")!
        if let data = defaults.data(forKey: "Schedule") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let schedule = try decoder.decode(Schedule.self, from: data)
                let dayToDayNumber = ["Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6, "Sun":7]
                let currentDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeNow = formatter.string(from: currentDate)
                let currentDayStart = Calendar.current.startOfDay(for: currentDate)
                let todayWeekdayName = currentDayStart.formatted(Date.FormatStyle().weekday().locale(Locale(identifier: "en_US")))
                let todayWeekday = dayToDayNumber[todayWeekdayName]!
                var nextWeekday = todayWeekday
                var nextTime = ""

                var nextLesson = Lesson(name: "Class", timeStart: "10:00", timeEnd: "11:00", colorR: 0.4, colorG: 0.1, colorB: 0.2, colorA: 0.8)
                var flag = 0
                while nextTime == ""{

                    if schedule.schedule == [1:[],2:[],3:[],4:[],5:[],6:[],7:[]]{
                        break
                    }


                    if !schedule.schedule[nextWeekday]!.isEmpty {
                        let lessons  = schedule.schedule[nextWeekday]!.sorted(by: {
                            let formatter1 = DateFormatter()
                            formatter1.dateFormat = "HH:mm"
                            return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!

                        })
                        for lesson in lessons {
                            let time = lesson.timeStart
                            if time > timeNow || nextWeekday != todayWeekday || flag == 7{
                                nextTime = time
                                nextLesson = lesson
                                break

                            }
                        }


                    }
                    if nextTime == ""{
                        nextWeekday = (nextWeekday) % 7 + 1
                        flag += 1
                    }
                }
                let startHours = Int(nextLesson.timeStart.components(separatedBy: ":")[0])!
                let startMinutes = Int(nextLesson.timeStart.components(separatedBy: ":")[1])!
                let dayDiff = (nextWeekday - todayWeekday + 7) % 7
                var nextDateComponents = DateComponents()
                nextDateComponents.hour = startHours
                nextDateComponents.minute = startMinutes
                nextDateComponents.day = dayDiff
                let startDate = Calendar.current.date(byAdding: nextDateComponents, to: currentDayStart)!
                let entry = NextLessonWidgetContent(lesson: nextLesson, nextDate: startDate)
                completion(entry)


            } catch {
                print("Unable to Decode schedule (\(error))")
                let entry = NextLessonWidgetContent(lesson: Lesson(name: "Class", timeStart: "10:00", timeEnd: "11:00", colorR: 0, colorG: 0.7, colorB: 0.7, colorA: 1), nextDate: Date(timeIntervalSinceNow: 60 * 10))
                completion(entry)
            }
        }

    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [NextLessonWidgetContent] = []


        let dayToDayNumber = ["Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6, "Sun":7]
        let currentDate = Date()
        let currentDayStart = Calendar.current.startOfDay(for: currentDate)
        let todayWeekdayName = currentDayStart.formatted(Date.FormatStyle().weekday().locale(Locale(identifier: "en_US")))
        let todayWeekday = dayToDayNumber[todayWeekdayName]!
        var lastDate = currentDate
            let defaults = UserDefaults(suiteName: "group.somePIE.ClassTimer")!
            if let data = defaults.data(forKey: "Schedule") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode Note
                    let schedule = try decoder.decode(Schedule.self, from: data)
                    for day in schedule.schedule.keys {
                        for lesson in schedule.schedule[day]!.sorted(by: {
                            let formatter1 = DateFormatter()
                            formatter1.dateFormat = "HH:mm"
                            return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
                        }) {
                            let startHours = Int(lesson.timeStart.components(separatedBy: ":")[0])!
                            let startMinutes = Int(lesson.timeStart.components(separatedBy: ":")[1])!
                            let dayDiff = (day - todayWeekday + 7) % 7
                            var nextDateComponents = DateComponents()
                            nextDateComponents.hour = startHours
                            nextDateComponents.minute = startMinutes
                            nextDateComponents.day = dayDiff
                            let startDate = Calendar.current.date(byAdding: nextDateComponents, to: currentDayStart)!

                            let entry = NextLessonWidgetContent(date: lastDate, lesson: lesson, nextDate: startDate)
                            entries.append(entry)
                            lastDate = startDate

                        }
                    }


                } catch {
                    print("Unable to Decode schedule (\(error))")
                    
                }
            }

        if entries.isEmpty{
            let entry = NextLessonWidgetContent(lesson: Lesson(name: "", timeStart: "", timeEnd: "", colorR: 0, colorG: 0.7, colorB: 0.7, colorA: 1), nextDate: Date(timeIntervalSinceNow: 60 * 10))
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}





struct NextLessonWidget: Widget {
    let kind: String = "NextLessonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextLessonProvider()) { entry in
            NextLessonWidgetView(entry: entry)
        }
        .configurationDisplayName("Next class")
        .description("Shows a countdown to your next class.")
        .supportedFamilies([.systemSmall])
    }
}
struct NextLessonWidgetView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: NextLessonWidgetContent


    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            EmptyView()
        case .systemLarge:
            EmptyView()
        case .systemSmall:
            NextLessonWidgetSmallView(entry: entry)
        case .systemExtraLarge:
            EmptyView()
        case .accessoryCircular:
            EmptyView()
        case .accessoryRectangular:
            EmptyView()
        case .accessoryInline:
            EmptyView()
        default:
            EmptyView()
        }
    }
}

struct NextLessonWidgetSmallView: View {
    let entry: NextLessonWidgetContent


    var body: some View {
        VStack{

            if entry.lesson.name != ""{
                VStack{
                    Text(entry.lesson.name)
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text("\(entry.lesson.timeStart)-\(entry.lesson.timeEnd), \(entry.nextDate.formatted(Date.FormatStyle().weekday()))")
                        .fontWeight(.thin)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 6)
                            .foregroundColor(Color(UIColor(red: entry.lesson.colorR, green: entry.lesson.colorG, blue: entry.lesson.colorB, alpha: entry.lesson.colorA)))
                        Text(entry.nextDate, style: .timer)
                            .font(.system(size: 44))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)



            } else {
                Text("No classes planned")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}




struct NextLessonWidget_Previews: PreviewProvider {
    static var previews: some View {
        NextLessonWidgetSmallView(entry: nextLessonSnapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

    }
}
