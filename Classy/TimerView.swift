//
//  TimerView.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 10.04.2023.
//

import SwiftUI
import UserNotifications

struct TimerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State var progressToClass: Double = 0.15
    @State var progressToExam: Double = 0.15
    @State var timeTo = "Class"
    @State var nextClassName = ""
    @State var nextExamName = ""
    @State var nextExamClassName = ""
    @State var timeToNextClass: Double = 100
    @State var timeToNextExam: Double = 100
    @Namespace var animation

    let timerClass = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timerExam = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func calculateTimeToNextClass() {

        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "en_US")
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm"
        formatter2.locale = Locale(identifier: "en_US")
        let timeNow = formatter2.string(from: today)
        let todayWeekday = dayToDayNumber[formatter.string(from: today)]!
        var nextWeekday = todayWeekday
        var nextTime = ""
        var nextName = ""

        var flag = 0
        while nextTime == ""{


            if viewModel.schedule.schedule == [1:[],2:[],3:[],4:[],5:[],6:[],7:[]]{
                break
            }


            if !viewModel.schedule.schedule[nextWeekday]!.isEmpty {
                let lessons  = viewModel.schedule.schedule[nextWeekday]!.sorted(by: {
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "HH:mm"
                    return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!

                })
                for lesson in lessons {
                    let time = lesson.timeStart
                    if time > timeNow || nextWeekday != todayWeekday || flag == 7{
                        nextTime = time
                        nextName = lesson.name
                        break

                    }
                }


            }
            if nextTime == ""{
                nextWeekday = (nextWeekday) % 7 + 1
                flag += 1
            }
        }
        nextClassName = nextName


        



        var intervalToNextClass: Int = 0
        if nextTime != ""{
            if nextWeekday == todayWeekday{
                let intr: Int = Int(formatter2.date(from: nextTime)! - formatter2.date(from: timeNow)!)
                intervalToNextClass += intr
            } else if nextWeekday > todayWeekday {
                let intr: Int = 60 * 60 * 24 * (nextWeekday - todayWeekday)
                let otherIntr: Int = Int(formatter2.date(from: nextTime)! - formatter2.date(from: timeNow)!)
                intervalToNextClass += intr + otherIntr
            } else {
                let intr: Int = 60 * 60 * 24 * (nextWeekday - todayWeekday + 7)
                let otherIntr: Int = Int(formatter2.date(from: nextTime)! - formatter2.date(from: timeNow)!)
                intervalToNextClass += intr + otherIntr

            }
            if flag == 7{
                intervalToNextClass += 60 * 60 * 24 * 7
            }
        }
        if viewModel.countdownStartTime == viewModel.countdownStartClassTime || Date() > viewModel.countdownStartClassTime || nextName != viewModel.countdownStartedForClass{
            viewModel.countdownStartTime = Date()
            viewModel.countdownStartClassTime = Date(timeIntervalSinceNow: TimeInterval(intervalToNextClass))
            viewModel.countdownTimeLength = Double(intervalToNextClass)
            viewModel.countdownStartedForClass = nextName
            viewModel.defaults.set(viewModel.countdownStartedForClass, forKey: "countdownStartedForClass")
            viewModel.defaults.set(viewModel.countdownStartTime, forKey: "countdownStartTime")
            viewModel.defaults.set(viewModel.countdownTimeLength, forKey: "countdownTimeLength")
            viewModel.defaults.set(viewModel.countdownStartClassTime, forKey: "countdownStartClassTime")

        } else {
            viewModel.countdownStartClassTime = Date(timeIntervalSinceNow: TimeInterval(intervalToNextClass))
            viewModel.defaults.set(viewModel.countdownStartClassTime, forKey: "countdownStartClassTime")
        }

        timeToNextClass = Double(intervalToNextClass)
        if viewModel.countdownTimeLength != 0 {

            progressToClass += (Date() - viewModel.countdownStartTime) * 0.7/viewModel.countdownTimeLength
        }

    }
    func calculateTimeToNextExam() {
        if !viewModel.exams.isEmpty{

            let nextExam = viewModel.exams.sorted(by: {
                $0.date < $1.date
            })[0]
            timeToNextExam = nextExam.date - Date()
            nextExamName = nextExam.name
            nextExamClassName = nextExam.cl.name
            if viewModel.countdownStartTimeExam == viewModel.countdownStartClassTimeExam || Date() > viewModel.countdownStartClassTimeExam || nextExamName != viewModel.countdownStartedForExam{
                viewModel.countdownStartTimeExam = Date()
                viewModel.countdownStartClassTimeExam = Date(timeIntervalSinceNow: TimeInterval(timeToNextExam))
                viewModel.countdownTimeLengthExam = Double(timeToNextExam)
                viewModel.countdownStartedForExam = nextExamName
                viewModel.defaults.set(viewModel.countdownStartedForExam, forKey: "countdownStartedForExam")
                viewModel.defaults.set(viewModel.countdownStartTimeExam, forKey: "countdownStartTimeExam")
                viewModel.defaults.set(viewModel.countdownTimeLengthExam, forKey: "countdownTimeLengthExam")
                viewModel.defaults.set(viewModel.countdownStartClassTimeExam, forKey: "countdownStartClassTimeExam")


            } else {
                viewModel.countdownStartClassTimeExam = Date(timeIntervalSinceNow: TimeInterval(timeToNextExam))
                viewModel.defaults.set(viewModel.countdownStartClassTimeExam, forKey: "countdownStartClassTimeExam")
                
            }

            if viewModel.countdownTimeLengthExam != 0 {
                progressToExam += (Date() - viewModel.countdownStartTimeExam) * 0.7/viewModel.countdownTimeLengthExam
            }

        } else {
            timeToNextExam = 0
        }

    }
    func intervalToStringClass(intervalToNextClass: Double) -> String {
        if intervalToNextClass == 0{
            return "No classes planned"
        } else {
            var roundedInterval = Int(intervalToNextClass)
            var timeString = ""
            var dayString = ""

            let days = String((roundedInterval - roundedInterval % 86400)/86400)
            roundedInterval = roundedInterval % 86400
            if days == "1"{
                dayString = "day"
            } else {
                dayString = "days"
            }
            let hours = String((roundedInterval - roundedInterval % 3600)/3600)
            roundedInterval = roundedInterval % 3600
            var minutes = String((roundedInterval - roundedInterval % 60)/60)
            if Int(minutes)! < 10 {
                minutes = "0" + minutes
            }
            var seconds = String(roundedInterval % 60)
            if Int(seconds)! < 10{
                seconds = "0" + seconds
            }
            timeString = "\(days) \(dayString) \(hours):\(minutes):\(seconds)"

            return timeString
        }
    }
    func intervalToStringExam(intervalToNextExam: Double) -> String {
        if intervalToNextExam == 0{
            return "No exams planned"
        } else {
            var roundedInterval = Int(intervalToNextExam)
            var timeString = ""
            var dayString = ""

            let days = String((roundedInterval - roundedInterval % 86400)/86400)
            roundedInterval = roundedInterval % 86400
            if days == "1"{
                dayString = "day"
            } else {
                dayString = "days"
            }
            let hours = String((roundedInterval - roundedInterval % 3600)/3600)
            roundedInterval = roundedInterval % 3600
            var minutes = String((roundedInterval - roundedInterval % 60)/60)
            if Int(minutes)! < 10 {
                minutes = "0" + minutes
            }
            var seconds = String(roundedInterval % 60)
            if Int(seconds)! < 10{
                seconds = "0" + seconds
            }
            timeString = "\(days) \(dayString) \(hours):\(minutes):\(seconds)"

            return timeString
        }
    }
    

    var body: some View {
        VStack {
            Picker("", selection: $timeTo) {
                Text("Class")
                    .tag("Class")
                Text("Exam")
                    .tag("Exam")

            }
            .pickerStyle(.segmented)
            .frame(alignment: .top)
            .padding()

            if timeTo == "Exam" && timeToNextExam != 0{



                    Text("Exam for \(nextExamClassName)")
                        .font(.system(size: 24, design: .rounded))
                        .bold()

                        .padding(4)



            }
            ZStack {
                if timeTo == "Class"{
                    ZStack{
                        Circle()
                            .trim(from: 0.15, to: 0.85)
                            .stroke(
                                viewModel.pickedColor.opacity(0.5),
                                style: StrokeStyle(
                                    lineWidth: 30,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(90))
                            .padding(32)
                        Circle()
                            .trim(from: 0.15, to: progressToClass)
                            .stroke(
                                viewModel.pickedColor,
                                
                                style: StrokeStyle(
                                    lineWidth: 30,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(90))
                            .animation(.easeOut, value: progressToClass)

                            .padding(32)
                            .matchedGeometryEffect(id: "progress", in: animation)


                        VStack{
                            if timeToNextClass != 0{
                                Text(nextClassName)
                                    .font(.system(size: 24, design: .rounded))
                                    .bold()

                                    .padding(4)
                                Text("in")
                                    .font(.system(size: 18, design: .rounded))
                                    .bold()

                                    .padding(4)
                            }
                            Text(intervalToStringClass(intervalToNextClass: timeToNextClass))
                                .font(.system(size: 24, design: .rounded))
                                .bold()

                                .padding(4)
                        }


                    }

                }
                if timeTo == "Exam"{
                    ZStack{
                        Circle()
                            .trim(from: 0.15, to: 0.85)
                            .stroke(
                                viewModel.pickedColor.opacity(0.5),
                                style: StrokeStyle(
                                    lineWidth: 30,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(90))
                            .padding(32)
                        Circle()
                            .trim(from: 0.15, to: progressToExam)
                            .stroke(
                                viewModel.pickedColor,
                                // 1
                                style: StrokeStyle(
                                    lineWidth: 30,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(90))
                            .animation(.easeOut, value: progressToExam)

                            .padding(32)
                            .matchedGeometryEffect(id: "progress", in: animation)
                        VStack{
                            if timeToNextExam != 0{
                            Text(nextExamName)
                                .font(.system(size: 24, design: .rounded))
                                .bold()

                                .padding(4)

                                Text("in")
                                    .font(.system(size: 18, design: .rounded))
                                    .bold()

                                    .padding(4)
                            }
                            Text(intervalToStringExam(intervalToNextExam: timeToNextExam))
                                .font(.system(size: 24, design: .rounded))
                                .bold()

                                .padding(4)
                        }

                    }


                }

            }

            
        }
        .onAppear{
            progressToClass = 0.15
            calculateTimeToNextClass()
            progressToExam = 0.15
            calculateTimeToNextExam()


        }
        .frame(maxHeight: .infinity, alignment: .top)

        .navigationTitle("Timer")

        .onReceive(timerClass) { time in
            
            if progressToClass < 0.85 && timeToNextClass != 0 {
                progressToClass = progressToClass + 0.7/(timeToNextClass)
                timeToNextClass = timeToNextClass - 1
            }
        }
        .onReceive(timerExam) { time in
            
            if progressToExam < 0.85 && timeToNextExam != 0 {
                progressToExam = progressToExam + 0.7/(timeToNextExam)
                timeToNextExam = timeToNextExam - 1
            }
        }

    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension Date {
    func dayNumberOfWeek() -> Int? {
        let ret = Calendar.current.dateComponents([.weekday], from: self).weekday
        if ret != 1{
            return ret! - 1
        } else {
            return 7
        }
    }
}
