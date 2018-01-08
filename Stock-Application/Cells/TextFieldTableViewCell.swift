//
//  TextFieldTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 9..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // ViewController의 viewDidLoad()와 비슷한 역할
        
        selectionStyle = .none // Cell이 선택되지 않게 하기 위해 // cellForRowAt에서 구현하면 두번 작성해야하기 때문에
        
        
    }
}
