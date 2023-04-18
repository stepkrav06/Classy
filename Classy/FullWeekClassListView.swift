//
//  FullWeekClassListView.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 16.04.2023.
//

import SwiftUI

struct FullWeekClassListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack{

            Text("Week")
                .fontWeight(.thin)
                .italic()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top)
                .padding(.horizontal)
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .frame(height: 2)
                .padding(.horizontal)
            List{
                ForEach(days, id: \.self) { day in
                    Section(header: Text(day)){
                        DayView(lessons: viewModel.schedule.schedule[dayToDayNumber[day]!] ?? [])
                    }

                }


            }
            .listStyle(.plain)
            .frame(maxHeight: 350)
            Spacer()



    }
    }
}

struct FullWeekClassListView_Previews: PreviewProvider {
    static var previews: some View {
        FullWeekClassListView()
    }
}
