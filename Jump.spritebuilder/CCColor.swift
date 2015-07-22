//
//  CCColor.swift
//  Jump
//
//  Created by Boris Yue on 7/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

extension CCColor {
    
    
    
     convenience init(r: Float, g: Float, b: Float)  {
        let redf = r / 255
        let greenf = g / 255
        let bluef = b / 255
        self.init(red: redf,green: greenf,blue: bluef)
    
    }
}
