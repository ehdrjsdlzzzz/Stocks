//
//  StocksViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 16..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SVProgressHUD

class StocksViewController: UIViewController {

    @IBOutlet weak var stocksTableView: UITableView!
    
    let segmentedControl = UISegmentedControl(items: ["그룹", "종목"])
    var stocks:[Stock] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        title = "종목"
        
        stocksTableView.delegate = self
        stocksTableView.dataSource = self
        stocksTableView.hideBottomSeparator()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add"), style: .plain, target: self, action: #selector(newStock))
        
        stocksTableView.register(UINib(nibName: StockTableViewCell.reuseableIdentifier, bundle:nil), forCellReuseIdentifier: StockTableViewCell.reuseableIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(saveStocks), name: Stock.didUpdate, object: nil)
        reloadStock()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        segmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stocksTableView.reloadData()
    }
}

// MARK: Additional method

extension StocksViewController  {
    @objc func saveStocks(){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(stocks), forKey: "stocks")
        UserDefaults.standard.synchronize()
    }
    func reloadStock(){
        if let data = UserDefaults.standard.object(forKey: "stocks") as? Data {
            stocks = try! PropertyListDecoder().decode([Stock].self, from: data)
        }
    }
}

// MARK: Target-Action
extension StocksViewController {
    @objc func segmentedControlChanged(){
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func refresh(){
        var updated = 0
        
        SVProgressHUD.show()
        
        for stock in stocks {
            self.parseStock(code: stock.code, success: { (updatedStock) in
                stock.price = updatedStock.price
                stock.isPriceKeep = updatedStock.isPriceKeep
                stock.isPriceUp = updatedStock.isPriceUp
                stock.priceDiff = updatedStock.priceDiff
                stock.rateDiff = updatedStock.rateDiff
                stock.exchange = updatedStock.exchange
                stock.dayChartImageUrl = updatedStock.dayChartImageUrl
                stock.monthChartImageUrl = updatedStock.monthChartImageUrl
                stock.threeMonthsChartImageUrl = updatedStock.threeMonthsChartImageUrl
                stock.yearChartImageUrl = updatedStock.yearChartImageUrl
                stock.threeYearsChartImageUrl = updatedStock.threeYearsChartImageUrl
                updated += 1
                if updated == self.stocks.count {
                    SVProgressHUD.dismiss()
                    self.saveStocks()
                    self.stocksTableView.reloadData()
                }
            })
        }
    }
    
    @objc func newStock(){
        let alert = UIAlertController(title: "새 종목", message: "종목 코드를 입력하세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "종목 코드"
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "추가", style: .default, handler: { _ in
            // 종목 받아오는 코드
            guard let code = alert.textFields?[0].text, !code.isEmpty else {return}
            
            SVProgressHUD.show()
            
            self.parseStock(code: code, success: { (stock) in
                self.stocks.append(stock)
                self.saveStocks()
                self.stocksTableView.reloadData()
            })
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func parseStock(code: String, success: @escaping ((Stock)->Void)){
        let siteURL = "http://finance.daum.net/item/main.daum?code=" + code
        
        Alamofire.request(siteURL).responseString { (response) in
            SVProgressHUD.dismiss()
            // Kanna로 파싱
            guard let html = response.result.value else { return }
            // HMTL -Kanna
            guard let doc = try? HTML(html: html, encoding: .utf8) else { return }
            
            // 종목 이름
            guard let titleElement = doc.at_css("#topWrap > div.topInfo > h2")  else {return}
            guard let title = titleElement.content else {return} // 실질적인 값. 제목
            // 종목 가격
            guard let priceElement = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(1) > em") else {return}
            guard let priceString = priceElement.content else {return}
            guard let price = Double(priceString.replacingOccurrences(of: ",", with: "")) else {return}
            
            // 종목 변동 사항
            let priceKeep = priceElement.className?.hasSuffix("keep") == true
            let priceUp = priceElement.className?.hasSuffix("up") == true
            
            // 가격 변동
            let priceDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(2) > span")?.content ?? ""
            let priceDiff = Double(priceDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            
            // 변동률
            var rateDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(3) > span")?.content ?? ""
            if rateDiffString.hasSuffix("％") || rateDiffString.hasSuffix("%") {
                rateDiffString = String(rateDiffString.dropLast())
            }
            if rateDiffString.hasPrefix("+") || rateDiffString.hasPrefix("-") {
                rateDiffString = String(rateDiffString.dropFirst())
            }
            let rateDiff = Double(rateDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            
            let exchange = doc.at_css("#topWrap > div.topInfo > ul.list_stockinfo > li:nth-child(2) > a")?.content
            
            let stock = Stock(name: title, code: code, price: price, isPriceUp: priceUp, isPriceKeep: priceKeep, priceDiff: priceDiff, rateDiff: rateDiff, exchange: exchange)
            
            stock.dayChartImageUrl = URL(string: doc.at_css("#stockGraphBody1")?["src"] ?? "")
            stock.monthChartImageUrl = URL(string: doc.at_css("#stockGraphBody2")?["src"] ?? "")
            stock.threeMonthsChartImageUrl = URL(string: doc.at_css("#stockGraphBody3")?["src"] ?? "")
            stock.yearChartImageUrl = URL(string: doc.at_css("#stockGraphBody4")?["src"] ?? "")
            stock.threeYearsChartImageUrl = URL(string: doc.at_css("#stockGraphBody5")?["src"] ?? "")
            
            // Chrome -> Inspector -> Copy Selector
            // #topWrap > div.topInfo > h2 // 이름 셀렉터
            // #topWrap > div.topInfo > ul.list_stockrate > li:nth-child(1) > em 가격 셀렉터
            
            // #topWrap > div.topInfo > ul.list_stockrate > li:nth-child(3) > span -> 변동률
            
            success(stock)
        }
    }
}

// MARK: UITableViewDataSource

extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.reuseableIdentifier, for: indexPath) as! StockTableViewCell
        
        cell.stock = stocks[indexPath.row]
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // to Selected Stock ViewController
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(StockViewController(stock: stocks[indexPath.row]), animated: true)
    }
}
