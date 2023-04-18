//
//  TabViewAdmin.swift
//
//  Tab view allowing to navigate the app for admin users
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State var selectedTab: Tab = .classes
    @State var color: Color = .blue
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottom){
                    Group{
                        switch selectedTab{
                        case .timer:
                            TimerView()
                        case .classes:
                            ClassListView()
                        case .settings:
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)


                        HStack{
                            ForEach(tabItems) { item in
                                Button {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)){
                                        selectedTab = item.tab

                                    }


                                } label: {
                                    VStack(spacing: 0){
                                        Image(systemName: item.icon)
                                            .symbolVariant(.fill)
                                            .font(.body.bold())
                                            .frame(width: 44, height: 29)
                                        Text(item.text)
                                            .font(.caption2)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .foregroundStyle(selectedTab == item.tab ? .primary : .secondary)
                                .blendMode(selectedTab == item.tab ? .overlay : .normal)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 14)
                        .frame(height: 88, alignment: .top)
                        .background(.ultraThinMaterial, in:
                                        RoundedRectangle(cornerRadius: 34, style: .continuous))
                        .opacity(1)
                        .background(

                                HStack{
                                    if selectedTab == .timer {
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }

                                    if selectedTab == .classes {
                                        Spacer()
                                    }
                                    if selectedTab == .settings {
                                        Spacer()
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }
                                    Circle().fill(viewModel.pickedColor).frame(width: 80)
                                    if selectedTab == .timer {
                                        Spacer()
                                    }

                                    if selectedTab == .classes {
                                        Spacer()
                                    }
                                    if selectedTab == .settings {
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }


                                }
                                .padding(.horizontal, 8)

                        )
                        .overlay(
                                HStack{
                                    if selectedTab == .timer {
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }

                                    if selectedTab == .classes {
                                        Spacer()
                                    }
                                    if selectedTab == .settings {
                                        Spacer()
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }
                                    Rectangle()
                                        .fill(viewModel.pickedColor)
                                        .frame(width: 28, height: 5)
                                        .cornerRadius(3)
                                        .frame(width: 88)
                                        .frame(maxHeight: .infinity, alignment: .top)
                                    if selectedTab == .timer {
                                        Spacer()
                                    }

                                    if selectedTab == .classes {
                                        Spacer()
                                    }
                                    if selectedTab == .settings {
                                        Spacer()
                                            .frame(width: geometry.size.width/24)
                                    }




                                }
                                .padding(.horizontal, 8)

                        )





                }


            }
        }
        
        
    }
}

struct TabViewAdmin_Previews: PreviewProvider {
    static let viewModel = AppViewModel()
    static var previews: some View {
        ContentView()
            .environmentObject(viewModel)
    }
}
