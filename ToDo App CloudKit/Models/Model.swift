//
//  Model.swift
//  ToDo App CloudKit
//
//  Created by Guilherme Ferreira Lenzolari on 20/03/24.
//

import Foundation
import CloudKit
import Combine

@MainActor //garante que a classe seja executada na fila principal (main thread) pois quando ela muda, a view tbm muda, o que é uma tarefa prioritária (tarefas prioritárias como mudanças na view devem ser realizadas na fila principal)
final class Model: ObservableObject {
    
    //dicionario que armazena os dados do banco de dados remoto
    //@Published par notificar a UI sobre as mudanças
    @Published private var taskDictionary: [CKRecord.ID: TaskItem] = [:]
    
    let container = CKContainer.init(identifier: "iCloud.icloud.todo") // Define o container do CloudKit usando o identificador específico.
    let db: CKDatabase // Declara uma variável para a base de dados pública do CloudKit.
    
    var tasks: [TaskItem] { // Computed property que retorna uma array de TaskItem a partir do dicionário.
        taskDictionary.values.compactMap{$0} // Converte os valores do dicionário para uma array, ignorando nulos.
    }
    
    init(){
        self.db = container.publicCloudDatabase // Atribui a base de dados pública do container ao atributo db.
    }
    
    func addTask(taskItem: TaskItem) async throws { //Função assíncrona para adicionar uma tarefa, pode lançar erros
        let record = try await db.save(taskItem.record) // Salva o registro da tarefa na base de dados e espera a conclusão.
        guard let task = TaskItem(record: record) else {return} // Tenta criar uma TaskItem a partir do registro, retorna se falhar.
        taskDictionary[task.recordId!] = task // Adiciona ou atualiza a tarefa no dicionário.
    }

    func populateTasks() async throws { // Função assíncrona para popular as tarefas a partir do CloudKit, pode lançar erros.
        let query = CKQuery(recordType: TaskRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dateAssigned", ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach{ record in
            taskDictionary[record.recordID] = TaskItem(record: record)
        }
    }
    
    func updateTask(editedTaskItem: TaskItem) async throws { // Função assíncrona para atualizar uma tarefa, pode lançar erros.
        taskDictionary[editedTaskItem.recordId!]?.isCompleted = editedTaskItem.isCompleted // Atualiza o campo 'isCompleted' no registro.
        
        do {
            let record = try await db.record(for: editedTaskItem.recordId!) // Busca o registro correspondente no CloudKit.
            record[TaskRecordKeys.isCompleted.rawValue] = editedTaskItem.isCompleted // Atualiza o campo 'isCompleted' no registro.
            try await db.save(record) // Salva o registro atualizado na base de dados.
        } catch {
            taskDictionary[editedTaskItem.recordId!] = editedTaskItem // Reverte ao estado editado no dicionário caso ocorra um erro.
            //throws an error to tell the user that something has happened and the update was not succed
        }
    }
    
    func filterTaskItem(by filterOptions: FilteredOptions) -> [TaskItem] { // Função para filtrar as tarefas baseadas em opções.
        switch filterOptions { // Filtra baseado na enum FilteredOptions.
        case .all: // Caso 'all', retorna todas as tarefas.
            return tasks
        case .completed: // Caso 'completed', retorna somente tarefas completas.
            return tasks.filter { $0.isCompleted }
        case .incomplete: // Caso 'incomplete', retorna somente tarefas não completas.
            return tasks.filter { !$0.isCompleted }
        }
    }
}
