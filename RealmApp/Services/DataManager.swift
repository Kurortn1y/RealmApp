//
//  DataManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
	func createTempData(completion: @escaping () -> Void) { // ДЛЯ СОЗДАНИЯ ПРИМЕРА ДЛЯ ПОЛЬЗОВАТЕЛЯ (Фейк данные)
		let shoppingList = TaskList()
		shoppingList.title = "Shopping List"
		
        let moviesList = TaskList( // НЕЧИТАБЕЛЬНЫЙ ВАРИАНТ ДЛЯ ПРИМЕРА РАКЛАДЫВАЕТ МАССИВ ПО СВОЙСТВАМ
			value: [
				"Movies List",
				Date(),
				[
					["Best film ever"],
					["The best of the best", "Must have", Date(), true]
				]
			]
		)
		
		let milk = Task()
		milk.title = "Milk"
        milk.note = "2L"  // КОРОЧЕ ТУТ ВАРИАНТЫ РАБОТЫ СО СВОЙСТВАМИ В ЭТОМ ФРЕЙМВОРКЕ
		
		let apples = Task(value: ["Apples", "2Kg"])
		let bread = Task(value: ["title": "Bread", "isComplete": true])
		
		shoppingList.tasks.append(milk)
		shoppingList.tasks.insert(contentsOf: [apples, bread], at: 1)
        
        // СОХРАНЯЕМ В ДРУГОМ ПОТОКЕ ,ЗАПИСЬ В БАЗУ НАДО ДЕЛАТЬ В ФОНОВОМ РЕЖИМЕ ЕСЛИ ЭТО ПРЕДПОЛАГАЕТ ЗАДЕРЖКУ ПО ВРЕМЕНИ!!! БУДЕТ ДОЛГО ВЫХОДИТЬ ИЗ viewDidLoad и показывать Launchscreen
        
		DispatchQueue.main.async {
			StorageManager.shared.save([shoppingList, moviesList])
			completion() // ХЗ ДЛЯ ЧЕГО ТИПА ДЛЯ ОБНОВЛЕНИЯ ДАТА СОРС
		}
	}
}
