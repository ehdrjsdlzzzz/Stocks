//
//  GroupTableViewCell.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 9..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stocksLabel: UILabel!
    
    var group: Group? {
        didSet {
            guard let group = group else { return }
            titleLabel.text = group.title
        }
    }
    var stocks: [Stock]? {
        didSet {
            guard let stocks = stocks else { return }
            let note = group?.note ?? ""
            if stocks.count > 0 {
                let stocksText = "\(stocks.count) 종목"
                let stockTitles = stocks.map { $0.name }.joined(separator: ", ")
                let stockLabelText = "\(note) · \(stocksText) · \(stockTitles)"
                stocksLabel?.text = stockLabelText
            } else {
                stocksLabel?.text = note
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        titleLabel.textColor = .themeBlue
        stocksLabel.numberOfLines = 0
        titleLabel.text = nil
        stocksLabel.text = nil
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        titleLabel.text = nil
        stocksLabel.text = nil
        
    }
}
