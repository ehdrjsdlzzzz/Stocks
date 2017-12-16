//
//  UITableView+Stock.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 9..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit

extension UITableView {
    func hideBottomSeparator() {
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
    }
}
