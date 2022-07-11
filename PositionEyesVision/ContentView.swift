//
//  ContentView.swift
//  PositionEyesVision
//
//  Created by Caroline LaDouce on 6/21/22.
//

import SwiftUI

struct ContentView: View {
    
    var boundingRectangle = Rectangle()
    var rectangleView = RectangleView()
    
    var rectStrokeColorFalse = Color.orange
    var rectStrokeColorTrue = Color.teal
    
    var textFalse = "Position both eyes within the rectangle"
    var textTrue = "Eyes are positioned within the rectangle"
    
    @State var isIn: Bool = false
    
    @State var rectOffsetX: CGFloat = 0
    @State var rectOffsetY: CGFloat = 0
    
    var body: some View {
        ZStack {
            
            // Diplay live front camera feed and user eye drawings
            CameraVisionView(
                rectangleOffsetX: $rectOffsetX,
                rectangleOffsetY: $rectOffsetY,
                
                isInBinding: $isIn
            )
            
            // Draw RectangleView
            RectangleViewToSwiftUI()
                .frame(width: rectangleView.rectangleWidth, height: rectangleView.rectangleHeight)
                .offset(x: rectOffsetX + rectangleView.offsetOriginX, y: rectOffsetY + rectangleView.offsetOriginY)
            
            // Draw bounding rectangle
            boundingRectangle
                .strokeBorder(isIn ? rectStrokeColorTrue : rectStrokeColorFalse, lineWidth: 4)
                .frame(width: rectangleView.rectangleWidth, height: rectangleView.rectangleHeight)
                .offset(x: rectOffsetX + rectangleView.offsetOriginX, y: rectOffsetY + rectangleView.offsetOriginY)
            
            VStack {
                
                // Text Label
                Text(isIn ? textTrue : textFalse)
                    .bold()
                    .frame(width: (UIScreen.main.bounds.width * 0.9), height: 50, alignment: .center)
                    .background(isIn ? Color.white.opacity(0.75) : Color.orange.opacity(0.75))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                Spacer()
            }
        }
    } // End body
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
