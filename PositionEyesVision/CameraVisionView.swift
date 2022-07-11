//
//  CameraVisionView.swift
//  PositionEyesVision
//
//  Created by Caroline LaDouce on 6/21/22.
//

import Foundation
import UIKit
import SwiftUI

struct CameraVisionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraVisionViewController
    
    let isInBindingPass: Binding<Bool>
    let rectangleOffsetXPass: Binding<CGFloat>
    let rectangleOffsetYPass: Binding<CGFloat>
    
    init(rectangleOffsetX: Binding<CGFloat>, rectangleOffsetY: Binding<CGFloat>, isInBinding: Binding<Bool>) {
        self.rectangleOffsetXPass = rectangleOffsetX
        self.rectangleOffsetYPass = rectangleOffsetY
        self.isInBindingPass = isInBinding
    }
    
    func makeUIViewController(context: Context) -> CameraVisionViewController {
        let vc = CameraVisionViewController()
        vc.isInBindingCVVC = self.isInBindingPass
        vc.rectOffsetXCVVC = self.rectangleOffsetXPass
        vc.rectOffsetYCVVC = self.rectangleOffsetYPass
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraVisionViewController, context: Context) {
        // Required func. No code neccessary.
    }
    
}
