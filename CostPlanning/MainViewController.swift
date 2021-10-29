//
//  MainViewController.swift
//  CostPlanning
//
//  Created by Nikita on 19.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    // main
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
        
        let value = Spending(value: ["Gazprom", "950 ₽"]) //формируем строку для БД
        try! realm.write { //добавляем значение в бд
            realm.add(value)
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource { //подписываемя под протоколы для tableViews и нужно создать файл типа UITableViewCell
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //колличество ячеек в таблице
        return spendingArray.count //возвращаем количество объектов в массиве из бд
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //параметры ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell //приводим к типу созданной ячейки. withIdentifier - идентификатор
        
        let spending = spendingArray[indexPath.row]
        
        cell.namePaymentCell.text = spending.payment
        return cell
    }
    
    
}
