//
//  FirstViewController.swift
//  CostPlanning
//
//  Created by Nikita on 19.10.2021.
//

import RealmSwift
import UIKit

class FirstViewController: UIViewController {
    
    let realm = try! Realm()
    var mainDataArray: Results<MainData>!

    @IBOutlet weak var tfBalance: UITextField!
    @IBOutlet weak var tfSaveMoney: UITextField!
    var calcDate: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainDataArray = realm.objects(MainData.self) //помещаем элементы из бд в массив
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter() //отображает формат даты
        dateFormatter.dateStyle = .short //выбираем средний формат даты
        dateFormatter.locale = Locale(identifier: "ru_RU") //локализирвоали вывод даты
        let dateValue = dateFormatter.string(from: sender.date) //переводит дату в тип Стринг
        print(dateValue)
        calcDate = dateValue
    }
    
    @IBAction func addInfoButton(_ sender: UIButton) {
        let mainData = self.realm.objects(MainData.self)
        let balance = tfBalance.text
        let saveMoney = tfSaveMoney.text
        
        if mainData.isEmpty { //проверяет есть ли строка в бд
            if balance != "" && saveMoney != "" && calcDate != "" {
            let value = MainData(value: [balance, calcDate, saveMoney, "1", "1"]) //формируем строку для  записи БД
            try! realm.write { //добавляем значение в бд
                realm.add(value)
                }
            }
        } else { //если в бд есть запись, то просто редактируем
            if balance != "" && saveMoney != "" && calcDate != "" {
                try! realm.write { //редактируем строку в бд
                    mainData[0].balance = balance!
                    mainData[0].calcDate = calcDate
                    mainData[0].saveMoney = saveMoney!
                    mainData[0].leftMoneyDay = ""
                    mainData[0].leftMoneyWeek = ""
                }
            }
        }
        
    }
}
