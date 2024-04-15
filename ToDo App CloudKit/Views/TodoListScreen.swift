//
//  TodoListScreen.swift
//  ToDo App CloudKit
//
//  Created by Guilherme Ferreira Lenzolari on 20/03/24.
//

import SwiftUI

enum FilteredOptions: String, CaseIterable, Identifiable {
    case all
    case completed
    case incomplete
}

extension FilteredOptions {
    
    var id: String {
        rawValue
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}

struct TodoListScreen: View {
    
    @State private var taskTitle: String = ""
    @EnvironmentObject private var model: Model
    @State private var filteredOption: FilteredOptions = .all
    
    private var filteredTaskItems: [TaskItem]  {
        model.filterTaskItem(by: filteredOption)
    }
    
    var body: some View {
        VStack {
            TextField("Enter task", text: $taskTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    //TO DO: add validation
                    let taskItem = TaskItem(title: taskTitle, dateAssigned: Date())
                    Task {
                        do {
                            try await model.addTask(taskItem: taskItem)
                        } catch {
                            print(error)
                        }
                    }
                }
            
            // segmented control
            Picker("Select", selection: $filteredOption) {
                ForEach(FilteredOptions.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }.pickerStyle(.segmented)
            
            TaskListView(taskItems: filteredTaskItems)
            
            Spacer()
        }.task {
            do{
                try await model.populateTasks()
            } catch {
                print(error)
            }
        }
        .padding()
    }
}

#Preview {
    TodoListScreen().environmentObject(Model())
}
