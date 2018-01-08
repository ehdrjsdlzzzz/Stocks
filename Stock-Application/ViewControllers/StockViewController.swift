//
//  StockViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import SVProgressHUD
import SafariServices

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
        
        amountField?.delegate = self
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        title = stock.name
        tableView.hideBottomSeparator()

        self.tableView.register(UINib(nibName: StockInfoTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: StockInfoTableViewCell.reuseableIdentifier)
        self.tableView.register(UINib(nibName: StockChartTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: StockChartTableViewCell.reuseableIdentifier)
        
        self.tableView.register(UINib(nibName: TextFieldTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reuseableIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveStock))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
}

// MARK: UITextFieldDelegate

extension StockViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amountField?.resignFirstResponder()
        return true
    }
}

// MARK: Target-Action
extension StockViewController{
    
    @objc func endEditing(){
        amountField?.resignFirstResponder()
    }
    
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
    
    @objc func keyboardWillShow(_ notification: Notification){
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height <= CGFloat(1136.0){
                self.view.frame.origin.y = -150
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height <= CGFloat(1136.0){
                self.view.frame.origin.y = 0
            }
        }
    }
}

extension StockViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else if section == 1 {
            return 3
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
                cell.textField.text = "\(stock.amount)"
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
        }else if indexPath.section == 1{
            var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseableIdentifier)
            if cell == nil {
                cell =  UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.reuseableIdentifier)
            }
            
            cell.textLabel?.font = .systemFont(ofSize: 15)
            cell.accessoryType = .disclosureIndicator
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "네이버 증권"
            }else if indexPath.row == 1 {
                cell.textLabel?.text = "다음 금융"
            }else if indexPath.row == 2 {
                cell.textLabel?.text = "Bloomberg"
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension StockViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
            var urlString: String?
            if indexPath.row == 0 {
                urlString = "http://finance.naver.com/item/main.nhn?code=\(stock.code)"
            } else if indexPath.row == 1 {
                urlString = "http://finance.daum.net/item/main.daum?code=" + stock.code
            } else if indexPath.row == 2 {
                urlString = "https://www.bloomberg.com/quote/\(stock.code):KS"
            }
            
            if let urlString = urlString, let url = URL(string: urlString) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil) // 앱 밖의 브저우저
                present(SFSafariViewController(url: url), animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}


