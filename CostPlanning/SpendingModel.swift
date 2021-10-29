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
    @objc dynamic var date = NSDate()
    
}
