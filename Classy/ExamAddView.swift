//
//  ExamAddView.swift
//  ClassTimer
//
//  Created by Степан Кравцов on 14.04.2023.
//

import SwiftUI

struct ExamAddView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var pickedDate: Date = Date()
    @State var chosenClass: Class = Class(name: "", daysTimes: [:], description: "", colorR: 0, colorG: 0, colorB: 0, colorA: 0, location: "")



    // Alerts
    @State private var emptyFieldsAlert = false
    @State private var createExamAlert = false
    var body: some View {
        VStack{
            ScrollView{
                Group{
                    Text("Name")
                        .fontWeight(.thin)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top)
                        .padding(.horizontal)
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .frame(height: 2)
                        .padding(.horizontal)
                    TextField("", text: $name)
                        .textFieldStyle(OvalTextFieldStyle())
                        .padding()
                    
                    Text("Date")
                        .fontWeight(.thin)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top)
                        .padding(.horizontal)
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .frame(height: 2)
                        .padding(.horizontal)
                }
                DatePicker("", selection: $pickedDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                
                
                
                Group{
                    Text("Class")
                        .fontWeight(.thin)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top)
                        .padding(.horizontal)
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .frame(height: 2)
                        .padding(.horizontal)
                }
                
                ForEach(viewModel.classes, id:\.self){ cl in
                    HStack{
                        Image(systemName: chosenClass.name == cl.name ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(chosenClass.name == cl.name ? viewModel.pickedColor : .black)
                            .frame(maxWidth: 30)

                        
                        Text(cl.name)
                            .fontWeight(.medium)
                            .frame(alignment: .leading)
                        
                        HStack{
                            Text(cl.description)
                                .fontWeight(.thin)
                            
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(Color(UIColor(red: cl.colorR, green: cl.colorG, blue: cl.colorB, alpha: cl.colorA)))
                                .frame(width: 2)
                                .padding(.trailing)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    }
                    
                    .frame(minHeight: 40)
                    .padding(.horizontal)
                    .onTapGesture {
                        chosenClass = cl
                    }
                    

                    

                }
                Button {
                    guard name != "", chosenClass.name != "" else {
                        emptyFieldsAlert.toggle()
                        return
                    }
                    createExamAlert.toggle()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1)
                        Text("Create exam")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 18))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .padding()
            }
        }
        .alert("Some fields are empty or no class was chosen. Cannot proceed.", isPresented: $emptyFieldsAlert) {
                    Button("OK", role: .cancel) { }
                }

        .alert("Are you sure you want to create this exam?", isPresented: $createExamAlert) {
            Button("OK", role: .cancel) {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yy HH:mm"
                let dateString = formatter.string(from: pickedDate)
                let exam = Exam(name: name, cl: chosenClass, date: pickedDate, dateString: dateString)
                var exams = viewModel.exams
                exams.append(exam)
                viewModel.exams = exams
                viewModel.encodeExams(objects: exams)
                dismiss()
            }
            Button("Cancel") {}
                }

        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ExamAddView_Previews: PreviewProvider {
    static var previews: some View {
        ExamAddView()
    }
}
