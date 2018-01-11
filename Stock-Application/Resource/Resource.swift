//
//  Resource.swift
//  Stock-Application
//
//  Created by 이동건 on 2018. 1. 11..
//  Copyright © 2018년 이동건. All rights reserved.
//
import Foundation

class Resource {
    static let shared: Resource = Resource()
    
    private init(){}
    var groups: [Group] = []
}

