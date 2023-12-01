//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {

	private var taskLists: Results<TaskList>!
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
		createTempData()
		taskLists = storageManager.realm.objects(TaskList.self)
		
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem // EDIT делатся чтоб было понятно пользователю что можно делать EDIT
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.title
        content.secondaryText = taskList.tasks.count.formatted()
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - UITableViewDelegate 
    // МЕТОД ДОБАВЛЯЕТ ЭЛЕМЕНТЫ СПРАВА! LEADING СЛЕВА
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row] // ДОСТАЕМ ЭЛЕМЕНТ ИЗ СПИСКА ЗАДАЧ ДЛЯ КНОПКИ
        
        // СОЗДАЕМ КНОПКИ 
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true) // isDone ЗАКРЫВАЕТ ЯЧЕЙКУ
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        //НАСТРОЙКА ЦВЕТА КНОПОК
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        // ВОЗВРАЩАЕМ, ИНИЦИАЛИЗИРУЕМ ЕГО ACTIONS
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return } // СОЗДАЕМ INDEXPATH НАЖАТИЯ ЯЧЕЙКИ ПОЛЬЗОВАТЕЛЯ ЧТОБ ИМЕННО ЕЕ ОПРЕДЕЛИТЬ ИМ
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row] // ОПРЕДЕЛЯЕМ ЕЕ
        tasksVC.taskList = taskList
    }

    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
}

// MARK: - AlertController
extension TaskListViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: taskList != nil ? "Edit List" : "New List",
            message: "Please set title for new task list"
        )
        
        alertBuilder
            .setTextField(taskList?.title)
            .addAction(title: taskList != nil ? "Update List" : "Save List", style: .default) { [weak self] newValue, _ in
                if let taskList, let completion {
                    self?.storageManager.edit(taskList, newValue: newValue)
                    completion()
                    return
                }
                
                self?.save(taskList: newValue)
            }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func save(taskList: String) {
		storageManager.save(taskList) { taskList in
			let rowIndex = IndexPath(row: taskLists.firstIndex(of: taskList) ?? 0, section: 0)
			tableView.insertRows(at: [rowIndex], with: .automatic)
		}
    }
	
    private func createTempData() { // ФЕЙК ДАННЫЕ ХЗ ДЛЯ ЧЕГО ЭТОТ КЛЮЧ И ОТКУДА !
		if !UserDefaults.standard.bool(forKey: "doneSt") {
			DataManager.shared.createTempData { [unowned self] in
				UserDefaults.standard.set(true, forKey: "doneSt")
				tableView.reloadData()
			}
		}
	}
}
