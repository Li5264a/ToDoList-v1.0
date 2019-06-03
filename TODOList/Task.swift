//
//  ToDo.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/30.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

class Task: NSObject,NSCoding {
    
    var name: String = "No Name"
    var isCheck: Bool = false
    
    let nameString = "name"
    let isCheckString = "isCheck"

    init(_ name: String) {
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameString)
        aCoder.encode(isCheck, forKey: isCheckString)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameString) as! String
        isCheck = aDecoder.decodeBool(forKey: isCheckString)
        super.init()
    }
}
