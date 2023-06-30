//
//  PointWrappers.swift
//  NethersTrap
//
//  Created by Eldrick Loe on 30/06/23.
//

import Foundation

class PointWrapper: NSObject, NSCoding {
    let point: CGPoint
    
    init(point: CGPoint) {
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        let x = aDecoder.decodeDouble(forKey: "x")
        let y = aDecoder.decodeDouble(forKey: "y")
        point = CGPoint(x: x, y: y)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Double(point.x), forKey: "x")
        aCoder.encode(Double(point.y), forKey: "y")
    }
}
