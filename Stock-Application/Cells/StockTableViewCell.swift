//
//  StockTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 17..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var stock:Stock? {
        didSet {
            guard let stock = stock else {return} // ? didSet이면 이미 값이 할당아닌가?
            
            nameLabel.text = stock.name
            priceLabel.text = "\(stock.priceText)    \(stock.priceDiffText)"
            amountLabel.text = "\(stock.amount)주"
            
            if stock.isPriceKeep {
                priceLabel.textColor = .black
            }else if stock.isPriceUp {
                priceLabel.textColor = .upRed
            }else {
                priceLabel.textColor = .downBlue
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = nil
        priceLabel.text = nil
        amountLabel.text = nil
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        priceLabel.text = nil
        amountLabel.text = nil
    }
}
