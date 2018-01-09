//
//  StockHeaderView.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 9..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class StockHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var Seperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let background = UIView(frame: self.bounds)
        background.backgroundColor = .white
        backgroundView = background
        

        titleLabel.textColor = .themeBlue
        Seperator.backgroundColor = .separator
    }
}
