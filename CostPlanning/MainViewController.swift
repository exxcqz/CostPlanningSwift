//
//  MainViewController.swift
//  CostPlanning
//
//  Created by Nikita on 19.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    let realm = try! Realm() //открывает базу данных
    var spendingArray: Results<Spending>! //массив для хранения записей бд

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceForDay: UILabel!
    @IBOutlet weak var balanceForWeek: UILabel!
    @IBOutlet weak var balanceSave: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self) //помещаем элементы из бд в массив
    }
    
    @IBAction func addBtn(_ sender: UIButton) {
        
        let value = Spending(value: ["Gazprom", "950 ₽"]) //формируем строку для  записи БД
        try! realm.write { //добавляем значение в бд
            realm.add(value)
        }
        
        tableView.reloadData() //обновляем таблицу вывода из бд
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource { //подписываемя под протоколы для tableViews и нужно создать файл типа UITableViewCell
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //колличество ячеек в таблице
        return spendingArray.count //возвращаем количество объектов в массиве из бд
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //параметры ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell //приводим к типу созданной ячейки. withIdentifier - идентификатор
        
        let spending = spendingArray[indexPath.row] //массив со значением ячеек indexPath - выбранная ячейка
        
        // Присваеваем полям значение из бд SpendingModel
        cell.namePaymentCell.text = spending.payment
        cell.costPaymentCell.text = spending.costPayment
        cell.datePaymentCell.text = "\(spending.date)"
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {//функция удаления ячейке из тейбл вью и бд
        
        let editingRow = spendingArray[indexPath.row] // массив со значениями из бд
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить") { [self] _, _ in //экшн по удалению из таблицы и бд
            try! self.realm.write { // удаляем значение из бд
                self.realm.delete(editingRow) //удаляем значение из бд по значению из  editingRow
                tableView.reloadData() //обновляем таблицу
            }
        }
        
        return [deleteAction]
    }
    
}
