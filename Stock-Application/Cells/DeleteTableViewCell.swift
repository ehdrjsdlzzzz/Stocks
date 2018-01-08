//
//  DeleteTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class DeleteTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textAlignment = .center
        textLabel?.textColor = .red
        textLabel?.font = .systemFont(ofSize: 15)
        textLabel?.text = "REMOVE"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
