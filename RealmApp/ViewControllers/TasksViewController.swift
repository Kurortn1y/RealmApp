//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

final class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
	private let storageManager = StorageManager.shared
    
	private var currentTasks: Results<Task>!  // [Task] = []
    private var completedTasks: Results<Task>! // [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.title
		
        // ФИЛЬТРУЕМ ПО СТРИНГЕ
		currentTasks = taskList.tasks.filter("isComplete = false")
		completedTasks = taskList.tasks.filter("isComplete = true")
         
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row] // ТУТ ОПРЕДЕЛЯЕМ ИЗ КАКОГО МАССИВА БУДЕТ INDEXPATH СРАБАТЫВАТЬ
        content.text = task.title
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 // Определяем в какой секции находится
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
             storageManager.delete(task)
             tableView.deleteRows(at: [indexPath], with: .automatic)
         }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true) // isDone ЗАКРЫВАЕТ ЯЧЕЙКУ
        }
        
        let doneTitle = task.isComplete ? "undone" : "done"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [weak self] _, _, isDone in
            self?.storageManager.done (task)
            let currentTaskIndex = IndexPath(
            row: self?.currentTasks.index(of: task) ?? 0,
            section: 0
            )
            let completedTaskIndex = IndexPath (
            row:self?.completedTasks.index(of: task) ?? 0,
            section: 1
            )
            let destinationIndexRow = indexPath.section == 0 ? completedTaskIndex : currentTaskIndex
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            
            isDone(true)
        }
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction,editAction,deleteAction])
    }
    
 
    
    
    
    
    
    
    @objc private func addButtonPressed() {
        showAlert()
    }

}

extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: task != nil ? "Edit Task" : "New Task",
            message: "What do you want to do?"
        )
        
        alertBuilder
            .setTextFields(title: task?.title, note: task?.note)
            .addAction(
                title: task != nil ? "Update Task" : "Save Task",
                style: .default
            ) { [weak self] taskTitle, taskNote in
                if let task, let completion {
                    // TODO: - edit task
                    return
                }
                self?.save(task: taskTitle, withNote: taskNote)
            }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func save(task: String, withNote note: String) { // ВЫЗЫВАЕТСЯ В АЛЕРТЕ
		storageManager.save(task, withNote: note, to: taskList) { task in
			let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
			tableView.insertRows(at: [rowIndex], with: .automatic)
		}
    }
}
