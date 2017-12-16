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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        segmentedControl.selectedSegmentIndex = 1
    }
}

// MARK: Target-Action
extension StocksViewController {
    @objc func segmentedControlChanged(){
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func refresh(){
        
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
            let siteURL = "http://finance.daum.net/item/main.daum?code=" + code
            
            Alamofire.request(siteURL).responseString { (response) in
                SVProgressHUD.dismiss()
                print(response.result.value)
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource

extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
