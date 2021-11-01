//
//  SpendingModel.swift
//  CostPlanning
//
//  Created by Nikita on 27.10.2021.
//

import RealmSwift

class Spending: Object { //создали столбцы для базы данных
    
    @objc dynamic var payment = ""
    @objc dynamic var costPayment = ""
    @objc dynamic var date = ""
}

class MainData: Object { //2-я бд для вывода расчетов
    @objc dynamic var balance = ""
    @objc dynamic var calcDate = ""
    @objc dynamic var saveMoney = ""
    @objc dynamic var leftMoneyDay = ""
    @objc dynamic var leftMoneyWeek = ""
}
