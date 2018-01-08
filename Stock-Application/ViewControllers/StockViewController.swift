//
//  StockViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import SVProgressHUD

class StockViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var stock:Stock
    var amountField: UITextField?
    
    
    init(stock: Stock){
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = stock.name
        tableView.hideBottomSeparator()

        self.tableView.register(UINib(nibName: StockInfoTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: StockInfoTableViewCell.reuseableIdentifier)
        self.tableView.register(UINib(nibName: StockChartTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: StockChartTableViewCell.reuseableIdentifier)
        
        self.tableView.register(UINib(nibName: TextFieldTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reuseableIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveStock))
    }
}

// MARK: Target-Action
extension StockViewController{
    @objc func saveStock(){
        if let amountText = amountField?.text, let amount = Int(amountText) {
            amountField?.resignFirstResponder()
            SVProgressHUD.showSuccess(withStatus: "Saved")
            SVProgressHUD.dismiss(withDelay: 1)
            stock.amount = amount
            NotificationCenter.default.post(name: Stock.didUpdate, object: nil) // update Noti
            self.tableView.reloadData()
        }
    }
}

extension StockViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: StockInfoTableViewCell.reuseableIdentifier, for: indexPath) as! StockInfoTableViewCell
            cell.stock = stock
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StockChartTableViewCell.reuseableIdentifier, for: indexPath) as! StockChartTableViewCell
            
            cell.stock = stock
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseableIdentifier, for: indexPath) as! TextFieldTableViewCell
            amountField = cell.textField
            cell.label.text = "보유수량"
            cell.textField.placeholder = "종목 보유수량"
            cell.textField.isEnabled = true // 밑의 셀이 재사용될 경우 false이기 때문에 입력을 할 수 없다.
            cell.textField.keyboardType = .numberPad
            return cell
        }else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseableIdentifier, for: indexPath) as! TextFieldTableViewCell
            cell.label.text = "평가금액"
            cell.textField.placeholder = "\(stock.value)"
            cell.textField.isEnabled = false
            return cell
            
        }
        return UITableViewCell()
    }
}

extension StockViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


