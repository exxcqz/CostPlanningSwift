//
//  MainViewController.swift
//  CostPlanning
//
//  Created by Nikita on 19.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    var mainDataArray: Results<MainData>!

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
            DispatchQueue.main.async { //переход на первый контроллер
                self.performSegue(withIdentifier: "goFirstSegue", sender: nil)
            }
        } else {
            updateMainInfo() //обновляем баланс и тд
        }
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) { //функция возвращения с первого контроллера, работает по кнопке добавить платеж
        updateMainInfo()
        }

    // кнопка добавления платежа
    @IBAction func addPayment(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Добавить платеж", message: "Введите название платежа и сумму", preferredStyle: .alert) //создаем окно alert контроллера
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { [self] action in //устанавливаем кнопку установить в алертконтроллере
            let textFieldName = alertController.textFields?[0].text
            let textFieldSum = alertController.textFields?[1].text
            
            if textFieldName != "" && textFieldSum != "" {
                let value = Spending(value: [textFieldName, textFieldSum, currentDate()]) //формируем строку для  записи БД
                try! self.realm.write { //добавляем значение в бд
                    self.realm.add(value)
                }
                
                sumAndSubtractBalance(number: Double(textFieldSum!)!, sumOrSub: true) //вычитаем сумму платежа из баланса
                updateMainInfo()
                tableView.reloadData() //обновляем таблицу вывода из бд
            }
        }
        
        alertController.addTextField { (namePayment) in //создаем поля для ввода
            namePayment.placeholder = "Название"
        }
        
        alertController.addTextField { (sumPayment) in //создаем поля для ввода
            sumPayment.placeholder = "Сумма"
            sumPayment.keyboardType = .asciiCapableNumberPad // тип клавитуры только цифры
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in } // устанавливаем кнопку отмены в контроллер
        alertController.addAction(alertInstall) // вызываем первое действие
        alertController.addAction(alertCancel) //вызываем действие отмены
        
        present(alertController, animated: true, completion: nil) // вызывает показ контрллера на экран
    }
    
    @IBAction func changeButton(_ sender: UIButton) { 
        performSegue(withIdentifier: "goFirstSegue", sender: nil) // переход на первый контроллер
    }
    
    
    func updateMainInfo() { // функция обновления лейблов
        let balance = Double(mainDataArray[0].balance)! - Double(mainDataArray[0].saveMoney)! //вычитаем из основного баланса, сумму из saveMoney
        balanceLabel.text = "\(balance) ₽" //помещаем баланс в лейбл
        
        calcDate.text = "до \(mainDataArray[0].calcDate)"
        
        let moneyForDay = calcMoneyForDay(balance: balance, dateNow: NSDate() as Date, dateCalc: stringToDate(strDate: mainDataArray[0].calcDate)) //расчет денег на 1 день
        balanceForDay.text = String(deductionOfCostsDay(moneyForDay: moneyForDay)) + " ₽" //вычитаем из баланса на день затраты, совершенные в этот же день и помещаем в лейбл
        
        balanceSave.text = mainDataArray[0].saveMoney + " ₽"
    }
    
    func calcMoneyForDay(balance: Double, dateNow: Date, dateCalc: Date) -> Double { //рассчитываем сколько денег на день
        let diffInDays = Calendar.current.dateComponents([.day], from: dateNow, to: dateCalc).day //получаем сколько дней между текущей датой и расчетной
        
        let result: Double = balance / Double(diffInDays! + 1) //делим наш баланс на количество дней
        return round(result * 100)/100
    }
    
    func stringToDate(strDate: String) -> Date { //меняем тип даты с String на Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: strDate)!
    }
    
    func sumAndSubtractBalance(number: Double, sumOrSub: Bool) { //функция редактирования баланса при добавлении или удалении платежа
        let resultBalance: Double?
        if sumOrSub {
            resultBalance = Double(mainDataArray[0].balance)! - number
        } else {
            resultBalance = Double(mainDataArray[0].balance)! + number
        }
        
        try! realm.write { //редактируем строку в бд
            mainDataArray[0].balance = String(resultBalance!) //меняем баланс в бд
        }
    }
    
    func currentDate() -> String { //функция для получения текущей даты
        let time = NSDate() //получаем текущую дату
        let formatter = DateFormatter() //меняем формат вывода даты
        formatter.dateFormat = "dd.MM.YYYY" //указываем как отображать дату
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // указатель временной зоны относительно гринвича
        return formatter.string(from: time as Date) //приводим дату к типу String
    }
    
    func deductionOfCostsDay(moneyForDay: Double) -> Double { // вычитаем из баланса на день затраты, совершенные в этот же день
        let filterSpendingArray = spendingArray.filter({ $0.date == self.currentDate() }) //фильтруем платежы по сегодняшней дате
        var result = 0.0
        
        for spendingString in filterSpendingArray { //суммируем все платежы, совершенные за текущий день
            result += Double(spendingString.costPayment)!
        }
        return round((moneyForDay - result) * 100)/100
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource { //подписываемся под протоколы для tableViews
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //колличество ячеек в таблице
        return spendingArray.count //возвращаем количество объектов в массиве из бд
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //параметры ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray[indexPath.row] //массив со значением ячеек indexPath - выбранная ячейка
        
        // Присваеваем полям значения из бд SpendingModel
        cell.namePaymentCell.text = spending.payment
        cell.costPaymentCell.text = spending.costPayment + " ₽"
        cell.datePaymentCell.text = "\(spending.date)"
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {//функция удаления ячейки из тейбл вью и бд!
        
        let editingRow = spendingArray[indexPath.row] // строка из массива со значениями из бд
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить") { [self] _, _ in //экшн по удалению из таблицы и бд
            
            sumAndSubtractBalance(number: Double(editingRow.costPayment)!, sumOrSub: false)
            
            try! self.realm.write { // удаляем значение из бд
                self.realm.delete(editingRow) //удаляем значение из бд по значению из  editingRow
                tableView.reloadData() //обновляем таблицу
            }
            
            updateMainInfo()
        }
        return [deleteAction]
    }
    
}
