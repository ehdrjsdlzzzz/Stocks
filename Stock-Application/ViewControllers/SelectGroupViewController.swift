//
//  SelectGroupViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class SelectGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let groups: [Group]
    let stock:Stock
    
    init(groups: [Group], stock: Stock){
        self.groups = groups
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
        tableView.hideBottomSeparator()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseableIdentifier)
        title = "그룹 선택"

    }
}

extension SelectGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseableIdentifier, for: indexPath)
        
        cell.textLabel?.text = groups[indexPath.row].title
        if groups[indexPath.row].title == self.stock.groupTitle {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension SelectGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if stock.groupTitle == groups[indexPath.row].title {
            stock.groupTitle = nil
        } else {
            stock.groupTitle = groups[indexPath.row].title
        }
        self.tableView.reloadData()
        NotificationCenter.default.post(name: Stock.didUpdate, object: nil)
    }
}
