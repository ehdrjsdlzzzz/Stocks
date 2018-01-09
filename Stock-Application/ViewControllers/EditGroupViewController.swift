//
//  EditGroupViewController.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 8..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit

class EditGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var titleField: UITextField?
    var noteField: UITextField?
    
    let group: Group? // 수정 or 삭제시 해당 그룹이 넘어오기 때문. -> Initializer 문제 발생
    
    var didSaveGroup: ((Group)->Bool)? // Closure를 통한 데이터 저장
    
    init(group: Group?) {
        self.group = group
        super.init(nibName: nil, bundle: nil) // 자식 클래스의 프로퍼티를 채운 후에는 반드시 그 상위에서는 Designate 생성자를 호출해야 합니다.
    } // 임의로 생성자를 만들었기 때문에 부모 클래스의 required 생성자를 생성해주어야 한다.
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = group?.title ?? "New Group"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save , target: self, action: #selector(save))
        
        // Cell Register
        tableView.register(UINib.init(nibName: TextFieldTableViewCell.reuseableIdentifier, bundle: nil) , forCellReuseIdentifier: TextFieldTableViewCell.reuseableIdentifier)
        
        tableView.register(DeleteTableViewCell.self, forCellReuseIdentifier: DeleteTableViewCell.reuseableIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleField?.becomeFirstResponder() // focus
    }
}


// MARK: target-actions

extension EditGroupViewController {
    @objc func cancel(){
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save(){
        guard let title = titleField?.text, let note = noteField?.text, !title.isEmpty else { return  }

        let alert = UIAlertController(title: "Alert", message: "이미 존재하는 그룹명입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        if let group = group {
            
            if group.title != title{
                let previousTitle = group.title
                
                group.title = title // 객체를 계속 참조하고 있기 때문에 가능한 일
                group.note = note // 객체를 계속 참조하고 있기 때문에 가능한 일
                
                if !didSaveGroup!(group) {
                    present(alert, animated: true, completion: nil)
                    group.title = previousTitle
                    return
                }
            }
        }else{
            let newGroup = Group(title: title, note: note)
            if (didSaveGroup?(newGroup))! == false{
                present(alert, animated: true, completion: nil)
                return
            }
        }
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource Protocol

extension EditGroupViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if group == nil {
            return 1
        }
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else if section == 1{
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseableIdentifier, for: indexPath) as! TextFieldTableViewCell
        if indexPath.section == 0{
            if indexPath.row == 0{
                titleField = cell.textField // GroupsViewController에서 접근해 값을 얻기 위해
                cell.label.text = "Title"
                cell.textField.returnKeyType = .next
                cell.textField.delegate = self
                cell.textField.text = group?.title
                cell.textField.placeholder = "Input stock Title"
                return cell
            }else if indexPath.row == 1{
                noteField = cell.textField // GroupsViewController에서 접근해 값을 얻기 위해
                cell.label.text = "Desc"
                cell.textField.returnKeyType = .done
                cell.textField.delegate = self
                cell.textField.text = group?.note
                cell.textField.placeholder = "Input stock description"
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DeleteTableViewCell.reuseableIdentifier, for: indexPath) as! DeleteTableViewCell
            
            return cell
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate Protocol

extension EditGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let alert = UIAlertController(title: "삭제", message: "그룹을 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                NotificationCenter.default.post(name: Group.didDelete, object: self.group)
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Register"
        }
        
        return ""
    }
}

// MARK: UITextFieldProtocol

extension EditGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            noteField?.becomeFirstResponder()
        }else if textField == noteField{
            save()
        }
        
        return true
    }
}
