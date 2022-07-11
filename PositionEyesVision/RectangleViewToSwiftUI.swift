//
//  RectangleViewToSwiftUI.swift
//  PositionEyesVision
//
//  Created by Caroline LaDouce on 7/11/22.
//

import Foundation
import UIKit
import SwiftUI

struct RectangleViewToSwiftUI: UIViewRepresentable {
    
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        RectangleView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Required func. No code.
    }
    
}
