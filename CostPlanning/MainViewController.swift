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
    var mainDataArray: Results<MainData>! //Массив для хранений записей бд со значениями баланса и тд

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceForDay: UILabel!
    @IBOutlet weak var balanceForWeek: UILabel!
    @IBOutlet weak var balanceSave: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calcDate: UILabel!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self) //помещаем элементы из бд в массив
        mainDataArray = realm.objects(MainData.self) //помещаем элементы из бд в массив
        if mainDataArray.isEmpty { // Если прила запускается в первый раз, то переводит на первый контроллер
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goFirstSegue", sender: nil)
            }
        } else {
            updateMainInfo() //обновляем баланс и тд
        }
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) { //функция возвращения с первого контроллера
        updateMainInfo() //обновляем баланс и тд
        }

    // кнопка добавления платежа
    @IBAction func addPayment(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Добавить платеж", message: "Введите название платежа и сумму", preferredStyle: .alert) //создаем окно alert контроллера
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { [self] action in //устанавливаем кнопку установить в алертконтроллере
            
            let textFieldName = alertController.textFields?[0].text //принимаем текст с первого textField
            let textFieldSum = alertController.textFields?[1].text //принимаем текст со второго textField
            
            if textFieldName != "" && textFieldSum != "" { //проверка чтобы поля не были пустыми
                
                let time = NSDate() //получаем текущую дату
                let formatter = DateFormatter() //меняем формат вывода даты
                formatter.dateFormat = "dd.MM.YYYY" //указываем как отображать дату
                formatter.timeZone = TimeZone(secondsFromGMT: 0) // указатель временной зоны относительно гринвича
                let resultDate = formatter.string(from: time as Date) //приводим дату к типу String
                
                let value = Spending(value: [textFieldName, "\(textFieldSum!) ₽", resultDate]) //формируем строку для  записи БД
                try! self.realm.write { //добавляем значение в бд
                    self.realm.add(value)
                }
                tableView.reloadData() //обновляем таблицу вывода из бд
            }
        }
        
        alertController.addTextField { (namePayment) in //создаем поля для ввода
            namePayment.placeholder = "Название" //надпись в текстфилде
        }
        
        alertController.addTextField { (sumPayment) in //создаем поля для ввода
            sumPayment.placeholder = "Сумма" //надпись в текстфилде
            sumPayment.keyboardType = .asciiCapableNumberPad // тип клавитуры только цифры
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in } // устанавливаем кнопку отмены в контроллер
        
        alertController.addAction(alertInstall) // вызываем первое действие
        alertController.addAction(alertCancel) //вызываем действие отмены
        
        present(alertController, animated: true, completion: nil) // вызывает показ контрллера на экран
    }
    
    func updateMainInfo() { // функция обновления данных из бд
        balanceLabel.text = mainDataArray[0].balance + " ₽" //помещаем баланс из бд в лейбл
        calcDate.text = "до \(mainDataArray[0].calcDate)" //помещаем дату из бд в лейбл
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
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {//функция удаления ячейке из тейбл вью и бд!
        
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
