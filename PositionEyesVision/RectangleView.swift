//
//  RectangleShape.swift
//  PositionEyesVision
//
//  Created by Caroline LaDouce on 6/22/22.
//

import Foundation
import UIKit

class RectangleView: UIView {
    
    var rectangleWidth: CGFloat = 0
    var rectangleHeight: CGFloat = 0
    
    var originX: CGFloat = 0
    var originY: CGFloat = 0
    
    var offsetOriginX: CGFloat = 0
    var offsetOriginY: CGFloat = 0
    
    override init(frame: CGRect) {
        
        rectangleWidth = UIScreen.main.bounds.width * 0.8
        rectangleHeight = UIScreen.main.bounds.height * 0.3
        
        offsetOriginX = 0
        offsetOriginY = -50
        
        originX = (UIScreen.main.bounds.width - (rectangleWidth)) / 2 + offsetOriginX
        originY = ((UIScreen.main.bounds.height - (rectangleHeight)) / 2) + offsetOriginY
        
        super.init(frame: frame)
        
        self.frame = CGRect(x: originX,
                            y: originY,
                            width: rectangleWidth,
                            height: rectangleHeight)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.systemPurple.withAlphaComponent(0.25)
    }
    
}

