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

// 그룹별로 종목을 묶어주기 위해
class StockSection {
    var group: Group?
    var stocks: [Stock]
    
    init(group: Group?, stocks: [Stock]) {
        self.group = group
        self.stocks = stocks
    }
}

class StocksViewController: UIViewController {

    @IBOutlet weak var stocksTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    
    let segmentedControl = UISegmentedControl(items: ["그룹", "종목"])
    
    var stockInSections: [StockSection] = []
    
    var stocks:[Stock] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = segmentedControl
    
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        title = "종목"
        
        if #available(iOS 10.0, *) {
            stocksTableView.refreshControl = refreshControl
        } else {
            stocksTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        stocksTableView.delegate = self
        stocksTableView.dataSource = self
        stocksTableView.hideBottomSeparator()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add"), style: .plain, target: self, action: #selector(newStock))
        
        stocksTableView.register(UINib(nibName: StockTableViewCell.reuseableIdentifier, bundle:nil), forCellReuseIdentifier: StockTableViewCell.reuseableIdentifier)
        stocksTableView.register(UINib(nibName: StockHeaderView.reuseableIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: StockHeaderView.reuseableIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(saveStocks), name: Stock.didUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteStock(_:)), name: Stock.didDelete, object: nil)
        reloadStock()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        segmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStock()
    }
}

// MARK: Additional method (Data)

extension StocksViewController  {
    @objc func saveStocks(){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(stocks), forKey: "stocks")
        reloadStock()
    }
    func reloadStock(){
        
        guard let groups = AppDelegate.shared.groupsViewController?.groups  else {return}
        guard let stockData = UserDefaults.standard.object(forKey: "stocks") as? Data else {return}
        guard let stocks = try? PropertyListDecoder().decode([Stock].self, from: stockData) else {return}
        self.stocks = stocks
        
        stockInSections.removeAll() // reload 될 때마다 추가될 것이니 이전의 값들을 지워준다.
        
        for group in groups {
            let stockSection = StockSection(group: group, stocks: stocks.filter({$0.groupTitle == group.title})) // 전체 종목 중 그룹 이름이 같은 종목끼리 묶어 준다.
            if stockSection.stocks.count > 0 {
                stockInSections.append(stockSection)
            }
        }
        
        let noGroupStock = stocks.filter({$0.groupTitle == nil})
        if noGroupStock.count > 0 {
            let noGroupsInSection = StockSection(group: nil, stocks: noGroupStock)
            stockInSections.insert(noGroupsInSection, at: 0) // 그룹이 없는 종목들은 맨 위에
        }
        
        // 1. reloadStock 안에서 테이블 뷰를 reload 해준다.
        // 2. saveStocks 에서 reloadStock()을 호출해즘으로 종목읩 변화가 생기면 바로바로 StockInSections를 모두 갱신한다.
        // 3. saveStocks -> reloadStock -> tableView.reloadData()를 해주니 삭제, 추가 에서 tableView.reloadData()를 해줄 필요가 없다.
        stocksTableView.reloadData()
    }
    
    @objc func deleteStock(_ notification: Notification){
        guard let toDeleteStock = notification.object as? Stock else {return}
        if let index = stocks.index(where: {
            $0.name == toDeleteStock.name

        }){
            stocks.remove(at: index)
        }
        saveStocks()
    }
}

// MARK: Target-Action
extension StocksViewController {
    @objc func segmentedControlChanged(){
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func refresh(){
        var updated = 0
        
        if !self.refreshControl.isRefreshing{
            SVProgressHUD.show()
        }
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
                    self.refreshControl.endRefreshing()
                    self.saveStocks()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return stockInSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockInSections[section].stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.reuseableIdentifier, for: indexPath) as! StockTableViewCell
        
        cell.stock = stockInSections[indexPath.section].stocks[indexPath.row]
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if stockInSections[section].group == nil {
            return nil
        }else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: StockHeaderView.reuseableIdentifier) as! StockHeaderView
            
            view.titleLabel.text = stockInSections[section].group?.title
            view.detailLabel.text = "\(stockInSections[section].stocks.count)종목"
            
            return view
        }
    }
}

// MARK: UITableViewDelegate

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // to Selected Stock ViewController
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(StockViewController(stock: stockInSections[indexPath.section].stocks[indexPath.row]), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if stockInSections[section].group == nil {
            return .leastNormalMagnitude
        }
        
        return CGFloat(38)
    }
}
