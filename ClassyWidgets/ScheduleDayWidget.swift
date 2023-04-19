//
//  ScheduleDayWidget.swift
//  ScheduleDayWidget
//
//  Created by Степан Кравцов on 18.04.2023.
//

import WidgetKit
import SwiftUI

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
struct ScheduleDayWidgetContent: TimelineEntry {
    var date = Date()
    let schedule: Schedule
}





let snapshotEntry = ScheduleDayWidgetContent(schedule: Schedule(schedule:[1:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],2:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],3:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],4:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],5:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],6:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)],7:[Lesson(name: "Math", timeStart: "10:30", timeEnd: "12:30", colorR: 0.3, colorG: 0.1, colorB: 0.6, colorA: 0.5),Lesson(name: "English", timeStart: "13:00", timeEnd: "15:00", colorR: 0.6, colorG: 0.1, colorB: 0.3, colorA: 0.5)]]))

struct ScheduleDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleDayWidgetContent {
        snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleDayWidgetContent) -> ()) {
        completion(snapshotEntry)

    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ScheduleDayWidgetContent] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()

        for dayOffset in 0 ..< 3 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let entryDateStart = Calendar.current.startOfDay(for: entryDate)
            let defaults = UserDefaults(suiteName: "group.somePIE.ClassTimer")!
            if let data = defaults.data(forKey: "Schedule") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode Note
                    let schedule = try decoder.decode(Schedule.self, from: data)


                    let entry = ScheduleDayWidgetContent(date: entryDateStart, schedule: schedule)
                    entries.append(entry)



                } catch {
                    print("Unable to Decode schedule (\(error))")
                }
            }

        }
        if entries.isEmpty{
            let entry = ScheduleDayWidgetContent(schedule: Schedule(schedule: [1:[],2:[],3:[],4:[],5:[],6:[],7:[]]))
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}




struct ScheduleDayWidget: Widget {
    let kind: String = "ScheduleDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleDayProvider()) { entry in
            ScheduleDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Day schedule")
        .description("Shows the next classes you have today.")
        .supportedFamilies([.systemLarge, .systemMedium])
    }
}
struct ScheduleDayWidgetView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: ScheduleDayWidgetContent


    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium: ScheduleDayWidgetMediumView(entry: entry)
        case .systemLarge: ScheduleDayWidgetLargeView(entry: entry)
        case .systemSmall:
            EmptyView()
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
struct ScheduleDayWidgetLargeView: View {
    let entry: ScheduleDayWidgetContent
    let dayToDayNumber = ["Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6, "Sun":7]

    let lessons: [Lesson]
    init(entry: ScheduleDayWidgetContent) {
        self.entry = entry
        self.lessons = (entry.schedule.schedule[dayToDayNumber[entry.date.formatted(Date.FormatStyle().weekday().locale(Locale(identifier: "en_US")))]!] ?? [])
    }
    var body: some View {
        VStack{
            Text(entry.date.formatted(Date.FormatStyle().weekday(.wide)).capitalized)

                .fontWeight(.thin)
                .italic()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 4)
                .padding(.horizontal, 4)
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .frame(height: 2)
                .offset(x:0,y:-10)
            if lessons != []{
                if lessons.count <= 5{



                    ForEach(lessons.sorted(by: {
                        let formatter1 = DateFormatter()
                        formatter1.dateFormat = "HH:mm"
                        return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
                    }), id:\.self){ lesson in
                        HStack{
                            VStack{
                                Text(lesson.timeStart)
                                    .fontWeight(.medium)
                                    .font(.system(size: 12))


                                Text(lesson.timeEnd)
                                    .fontWeight(.thin)
                                    .font(.system(size: 12))


                            }
                            .frame(minWidth:40)
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(Color(UIColor(red: lesson.colorR, green: lesson.colorG, blue: lesson.colorB, alpha: lesson.colorA)))
                                .frame(width: 2)
                                .padding(.trailing)
                            VStack{
                                Text(lesson.name)
                                    .fontWeight(.medium)

                            }
                            Spacer()


                        }
                        .offset(x:0,y:-10)
                        .frame(maxHeight:35)
                        Divider()
                            .offset(x:0,y:-10)
                    }

            } else {



                ForEach(lessons.sorted(by: {
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "HH:mm"
                    return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
                })[0...4], id:\.self){ lesson in
                    HStack{
                        VStack{
                            Text(lesson.timeStart)
                                .fontWeight(.medium)
                                .font(.system(size: 12))


                            Text(lesson.timeEnd)
                                .fontWeight(.thin)
                                .font(.system(size: 12))


                        }
                        .frame(minWidth:40)
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .foregroundColor(Color(UIColor(red: lesson.colorR, green: lesson.colorG, blue: lesson.colorB, alpha: lesson.colorA)))
                            .frame(width: 2)
                            .padding(.trailing)
                        VStack{
                            Text(lesson.name)
                                .fontWeight(.medium)

                        }
                        Spacer()


                    }
                    .offset(x:0,y:-10)
                    .frame(maxHeight:35)
                    Divider()
                        .offset(x:0,y:-10)
                }

        }
            } else {
                Text("No classes planned")
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}
struct ScheduleDayWidgetMediumView: View {
    let entry: ScheduleDayWidgetContent
    let dayToDayNumber = ["Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6, "Sun":7]

    let lessons: [Lesson]
    init(entry: ScheduleDayWidgetContent) {
        self.entry = entry
        self.lessons = (entry.schedule.schedule[dayToDayNumber[entry.date.formatted(Date.FormatStyle().weekday().locale(Locale(identifier: "en_US")))]!] ?? [])
    }
    var body: some View {
        VStack{
            Text(entry.date.formatted(Date.FormatStyle().weekday(.wide).locale(Locale(identifier: "en_US"))))
                .fontWeight(.thin)
                .italic()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 4)
                .padding(.horizontal, 4)
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .frame(height: 2)
                .offset(x:0,y:-10)
            if lessons != []{
                if lessons.count <= 2{



                    ForEach(lessons.sorted(by: {
                        let formatter1 = DateFormatter()
                        formatter1.dateFormat = "HH:mm"
                        return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
                    }), id:\.self){ lesson in
                        HStack{
                            VStack{
                                Text(lesson.timeStart)
                                    .fontWeight(.medium)
                                    .font(.system(size: 12))


                                Text(lesson.timeEnd)
                                    .fontWeight(.thin)
                                    .font(.system(size: 12))


                            }
                            .frame(minWidth:40)
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(Color(UIColor(red: lesson.colorR, green: lesson.colorG, blue: lesson.colorB, alpha: lesson.colorA)))
                                .frame(width: 2)
                                .padding(.trailing)
                            VStack{
                                Text(lesson.name)
                                    .fontWeight(.medium)

                            }
                            Spacer()


                        }
                        .offset(x:0,y:-10)
                        .frame(maxHeight:35)
                        Divider()
                            .offset(x:0,y:-10)
                    }

            } else {



                ForEach(lessons.sorted(by: {
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "HH:mm"
                    return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
                })[0...1], id:\.self){ lesson in
                    HStack{
                        VStack{
                            Text(lesson.timeStart)
                                .fontWeight(.medium)
                                .font(.system(size: 12))


                            Text(lesson.timeEnd)
                                .fontWeight(.thin)
                                .font(.system(size: 12))


                        }
                        .frame(minWidth:40)
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .foregroundColor(Color(UIColor(red: lesson.colorR, green: lesson.colorG, blue: lesson.colorB, alpha: lesson.colorA)))
                            .frame(width: 2)
                            .padding(.trailing)
                        VStack{
                            Text(lesson.name)
                                .fontWeight(.medium)

                        }
                        Spacer()


                    }
                    .offset(x:0,y:-10)
                    .frame(maxHeight:35)
                    Divider()
                        .offset(x:0,y:-10)
                }

        }
            } else {
                Text("No classes planned")
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}





struct ScheduleDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleDayWidgetLargeView(entry: snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        ScheduleDayWidgetMediumView(entry: snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
