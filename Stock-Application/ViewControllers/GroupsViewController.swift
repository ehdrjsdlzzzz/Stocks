//
//  GroupsViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 8..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit
import SVProgressHUD

class GroupsViewController: UIViewController {

    @IBOutlet weak var groupTableView: UITableView!
    
    var groups: [Group] = []
    var stocks: [Stock] = []
    let segmentedControl = UISegmentedControl(items: ["그룹", "종목"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(deleteGroup(_ :)), name: Group.didDelete, object: nil)
        
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add_folder"), style: .plain, target: self, action: #selector(newGroup))
        
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupTableView.hideBottomSeparator()
        
        groupTableView.register(UINib(nibName: GroupTableViewCell.reuseableIdentifier, bundle: nil), forCellReuseIdentifier: GroupTableViewCell.reuseableIdentifier)
        self.reload() // load data when view did load
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
}

// MARk: Function about data

extension GroupsViewController {
    
    @objc func deleteGroup(_ noti: Notification){
        guard let groupToDelete = noti.object as? Group else { return }
        guard let index = groups.index(where: {$0.title == groupToDelete.title}) else {return}
        groups.remove(at: index)
        saveGroups()
        groupTableView.reloadData()
    }
    func saveGroups(){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(groups), forKey: "groups")
    }
    
    func reload(){
        if let data = UserDefaults.standard.object(forKey: "groups") as? Data {
            groups = try! PropertyListDecoder().decode([Group].self, from: data)
        }
        
        guard let stocksData = UserDefaults.standard.object(forKey: "stocks") as? Data else {return}
        guard let stocks = try? PropertyListDecoder().decode([Stock].self, from: stocksData) else {return}
        
        self.stocks = stocks
        groupTableView.reloadData()
    }
}

// MARK: target-actions

extension GroupsViewController {
    // 그룹 편집 화면 띄우기
    
    @objc func segmentedControlChanged(){
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func newGroup(){
        let editVC = EditGroupViewController(group: nil) // 새로운 그룹을 만들어주는 것이기 때문에 nil을 넘긴다.
 
        editVC.didSaveGroup = { (group) in
            if self.groups.contains(where: { $0.title == group.title }){
                print("has same name")
                return false // 추가하려는 그룹명이 이미 존재한다면 true를 반환
            }
            self.groups.append(group)
            self.saveGroups()
            self.groupTableView.reloadData()
            return true
        }
        present(UINavigationController(rootViewController: editVC), animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource Protocol

extension GroupsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.reuseableIdentifier, for: indexPath) as! GroupTableViewCell
        cell.group = groups[indexPath.row]
        cell.stocks = self.stocks.filter({$0.groupTitle == groups[indexPath.row].title})
        return cell
    }
}

// MARK: UITableViewDelegate Protocol

extension GroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 그룹 셀을 눌렀을 때 해당 그룹을 수정 or 삭제를 하는 화면(EditViewController)로 넘어가야 한다.
        let editVC = EditGroupViewController(group: groups[indexPath.row])
        
        editVC.didSaveGroup = { group in
            let isSameTitle = self.groups.filter({$0.title == group.title})
            if isSameTitle.count > 1{ // 1인 이유는 참조 값으로 넘어가면 본인의 이름도 같이 바뀌어 검사되어 카운트되기 때문이다.
                
                return false
            }
            self.saveGroups()
            self.groupTableView.reloadData()
            return true
        }
        
        present(UINavigationController(rootViewController: editVC), animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            groups.remove(at: indexPath.row)
            saveGroups()
            groupTableView.reloadData()
        }
    }
}
