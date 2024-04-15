//
//  ToDo_App_CloudKitApp.swift
//  ToDo App CloudKit
//
//  Created by Guilherme Ferreira Lenzolari on 20/03/24.
//

import SwiftUI

@main
struct ToDoCloudKitApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListScreen().environmentObject(Model())
        }
    }
}
