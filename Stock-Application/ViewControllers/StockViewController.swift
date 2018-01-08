//
//  StockViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class StockViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var stock:Stock
    
    init(stock: Stock){
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = stock.name
        tableView.hideBottomSeparator()

        self.tableView.register(UINib(nibName: StockInfoTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: StockInfoTableViewCell.reuseableIdentifier)
    }
}

extension StockViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: StockInfoTableViewCell.reuseableIdentifier, for: indexPath)
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


