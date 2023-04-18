//
//  DayView.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 10.04.2023.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var lessons: [Lesson]
    var body: some View {
        if !lessons.isEmpty{

            ForEach(lessons.sorted(by: {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "HH:mm"
                return formatter1.date(from: $0.timeStart)! < formatter1.date(from: $1.timeStart)!
            })) { lesson in
                HStack{
                    VStack{
                        Text(lesson.timeStart)
                            .fontWeight(.medium)
                            .font(.system(size: 12))
                            .padding(.leading, 4)

                        Text(lesson.timeEnd)
                            .fontWeight(.thin)
                            .font(.system(size: 12))
                            .padding(.leading, 4)

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
            }
        } else {
            Text("No classes")
        }








    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(lessons: [])
    }
}
