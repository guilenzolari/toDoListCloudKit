//
//  TaskListView.swift
//  ToDo App CloudKit
//
//  Created by Guilherme Ferreira Lenzolari on 03/04/24.
//

import SwiftUI

struct TaskListView: View {
    
    let taskItems: [TaskItem]
    @EnvironmentObject private var model: Model
    
    var body: some View {
        List(taskItems, id: \.recordId) { taskItem in
            TaskItemView(taskItem: taskItem, onUpdate: { editedTask in
                Task {
                    do {
                        try await model.updateTask(editedTaskItem: editedTask)
                    } catch {
                        print(error)
                    }
                }
                
            })
        }
    }
}

#Preview {
    TaskListView(taskItems: []).environmentObject(Model())
}
