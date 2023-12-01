//
//  Extension + TableViewCell.swift
//  RealmApp
//
//  Created by Roman on 01.12.23.
//  Copyright © 2023 Alexey Efimov. All rights reserved.
//

import UIKit

// MARK: - Расширение для ячейки

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter("isComplete = false")
        var content = defaultContentConfiguration()
        
        content.text = taskList.title
        
        if taskList.tasks.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currentTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = currentTasks.count.formatted()
            accessoryType = .none
        }
        contentConfiguration = content
    }
}
