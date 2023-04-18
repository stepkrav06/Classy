//
//  SettingsView.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 10.04.2023.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.scenePhase) private var phase
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var viewModel: AppViewModel
    @State private var customColor =
    Color(.sRGB, red: 0, green: 0, blue: 0)
    @State var notificationStatus: Bool = false
    @State var wantSecondNotification: Bool = false
    @State var firstNotificationTime = "None"
    @State var secondNotificationTime = "None"
    var notificationTimes: [String] = ["None", "5 min before", "10 min before", "15 min before","30 min before", "1 hour before","2 hours before"]
   

    


    var body: some View {
        VStack(spacing: 5){
            Group{
                Text("Accent color")
                    .fontWeight(.thin)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top)
                    .padding(.horizontal)
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .frame(height: 2)
                    .padding(.horizontal)
            }

                HStack {
                    ForEach(viewModel.colors, id: \.self){ color in
                        ZStack {
                            Circle().fill(color).frame(width: 22).padding(4)
                                .onTapGesture {
                                    viewModel.pickedColor = color
                                    viewModel.defaults.setColor(color: UIColor(color), forKey: "AccentColor")
                                }
                            if UIColor(viewModel.pickedColor).cgColor.components == UIColor(color).cgColor.components{
                                Circle().fill(color).frame(width: 28)
                            }
                        }
                    }
                    ColorPicker("", selection: $viewModel.pickedColor)
                        .frame(maxWidth:20)
                        



                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Group{
                Text("Notifications")
                    .fontWeight(.thin)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top)
                    .padding(.horizontal)
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .frame(height: 2)
                    .padding(.horizontal)
            }

            Toggle("Class notifications", isOn: $notificationStatus)
                .toggleStyle(SwitchToggleStyle(tint: viewModel.pickedColor))
                .onChange(of: notificationStatus) { value in
                    viewModel.wantNotifications = value
                    viewModel.defaults.setValue(value, forKey: "wantNotifications")
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")


                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    if value {
                        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                        if !isRegisteredForRemoteNotifications {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }

                    }
                }

                .font(.system(size: 20, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top)
            .padding(.horizontal)
            VStack{

                    List{

                            Picker("First", selection: $firstNotificationTime) {
                                ForEach(notificationTimes, id: \.self) {
                                    Text($0)
                                }
                            }
                            .onChange(of: firstNotificationTime){ time in
                                viewModel.firstNotificationTime = stringToTimeInterval[time]!
                                viewModel.defaults.set(stringToTimeInterval[time]!, forKey: "firstNotificationTime")

                            }



                            Picker("Second", selection: $secondNotificationTime) {
                                ForEach(notificationTimes, id: \.self) {
                                    Text($0)
                                }
                            }
                            .onChange(of: secondNotificationTime){ time in
                                if time != "None" {
                                    viewModel.wantSecondNotification = true
                                    viewModel.defaults.setValue(true, forKey: "wantSecondNotification")
                                } else {
                                    viewModel.wantSecondNotification = false
                                    viewModel.defaults.setValue(false, forKey: "wantSecondNotification")
                                }
                                viewModel.secondNotificationTime = stringToTimeInterval[time]!
                                viewModel.defaults.set(stringToTimeInterval[time]!, forKey: "secondNotificationTime")

                            }
                            

                    }
                
                    .scrollContentBackground(.hidden)

                    .frame(maxHeight: 150)


                .scrollDisabled(true)


            }

                

            Group{
                Text("Appearance")
                    .fontWeight(.thin)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top)
                    .padding(.horizontal)
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .frame(height: 2)
                    .padding(.horizontal)
                
            }
            Toggle(isOn: $isDarkMode){
                Text("Dark mode")
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .topLeading)


            }
            .toggleStyle(SwitchToggleStyle(tint: viewModel.pickedColor))
            .padding(.top)
            .padding(.horizontal)
            Spacer()




        }
        .onAppear(){
            firstNotificationTime = timeIntervalToString[viewModel.firstNotificationTime]!
            secondNotificationTime = timeIntervalToString[viewModel.secondNotificationTime]!

            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .denied {
                    notificationStatus = false
                } else if settings.authorizationStatus == .authorized {
                    notificationStatus = true
                }
            })
        }
        .onChange(of: phase) { newPhase in
                    switch newPhase {
                    case .active :
                        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                            if settings.authorizationStatus == .denied {
                                notificationStatus = false
                            } else if settings.authorizationStatus == .authorized {
                                notificationStatus = true
                            }
                        })

                    default: break
                    }
                }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let viewModel = AppViewModel()
    static var previews: some View {
        SettingsView()
            .environmentObject(viewModel)
    }
}

struct CheckToggleStyle: ToggleStyle {
    @EnvironmentObject var viewModel: AppViewModel
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? viewModel.pickedColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
