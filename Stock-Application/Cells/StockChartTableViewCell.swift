//
//  StockChartTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import PINRemoteImage

class StockChartTableViewCell: UITableViewCell {

    @IBOutlet weak var charImageVIew: UIImageView!
    
    var stock: Stock? {
        didSet{
            charImageVIew.pin_setImage(from: stock?.monthChartImageUrl)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        selectionStyle = .none
    }
}

