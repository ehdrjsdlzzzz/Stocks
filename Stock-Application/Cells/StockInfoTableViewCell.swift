//
//  StockInfoTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 8..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class StockInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var stockCodeLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var priceDiffLabel: UILabel!
    
    var stock:Stock? {
        didSet{
            guard let stock = stock else {return}
            var stockCodeText = stock.code
            if let exchange = stock.exchange{
                stockCodeText += " | \(exchange)"
            }
            
            stockCodeLabel.text = stockCodeText
            currentPriceLabel.text = "KRW \(stock.priceText)"
            priceDiffLabel.text = stock.priceDiffText
            if stock.isPriceKeep {
                currentPriceLabel.textColor = .textDark
                priceDiffLabel.textColor = .darkGray;
            }else if stock.isPriceUp {
                currentPriceLabel.textColor = .upRed
                priceDiffLabel.textColor = .upRed
            }else{
                currentPriceLabel.textColor = .downBlue
                priceDiffLabel.textColor = .downBlue
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stockCodeLabel.text = nil
        currentPriceLabel.text = nil
        priceDiffLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stockCodeLabel.text = nil
        currentPriceLabel.text = nil
        priceDiffLabel.text = nil
    }
}
