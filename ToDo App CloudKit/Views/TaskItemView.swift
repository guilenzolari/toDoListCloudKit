//
//  TaskItemView.swift
//  ToDo App CloudKit
//
//  Created by Guilherme Ferreira Lenzolari on 14/04/24.
//

import SwiftUI


struct TaskItemView: View {
    
    let taskItem: TaskItem
    let onUpdate: (TaskItem) -> Void
    
    var body: some View {
        HStack{
            Text(taskItem.title)
            Spacer()
            Image(systemName: taskItem.isCompleted ? "checkmark.square" : "square")
                .onTapGesture {
                    var taskItemToUpdate = taskItem
                    taskItemToUpdate.isCompleted = !taskItem.isCompleted
                    onUpdate(taskItemToUpdate)
                }
        }
    }
}

#Preview {
    TaskItemView(taskItem: TaskItem(title: "Mow the law", dateAssigned: Date()), onUpdate: { _ in })
}
