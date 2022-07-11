//
//  CameraVisionViewController.swift
//  PositionEyesVision
//
//  Created by Caroline LaDouce on 6/21/22.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI

class CameraVisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var isInBindingCVVC: Binding<Bool>?
    var rectOffsetXCVVC: Binding<CGFloat>?
    var rectOffsetYCVVC: Binding<CGFloat>?
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    let rectangleView = RectangleView()
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    
    // Contains eye drawings
    private var boxDrawings: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemPink
        self.addCameraInput()
        self.addPreviewLayer()
        self.getCameraFrames()
        self.captureSession.startRunning()
        
        rectangleView.backgroundColor = UIColor.clear
        
        self.view.addSubview(rectangleView)
    }
    
    
    override func viewDidLayoutSubviews() {
        
        xOffset = (UIScreen.main.bounds.width - view.safeAreaLayoutGuide.layoutFrame.width) / 2
        yOffset = (UIScreen.main.bounds.height - view.safeAreaLayoutGuide.layoutFrame.height) / 2
        
        if let offsetXBinding = self.rectOffsetXCVVC {
            offsetXBinding.wrappedValue = xOffset
        }
        
        
        if let offsetYBinding = self.rectOffsetYCVVC {
            offsetYBinding.wrappedValue = yOffset
        }
        
        rectangleView.frame = rectangleView.frame
        //        rectangleView.frame = CGRect(x: rectangleView.frame.origin.x - xAxisOffset,
        //                                     y: rectangleView.frame.origin.y - yAxisOffset,
        //                                     width: rectangleView.frame.width,
        //                                     height: rectangleView.frame.height)
        
        // Add PreviewLayer to display live camera feed
        previewLayer.frame = UIScreen.main.bounds
    }
    
    
    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
        previewLayer.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .front).devices.first else {
            fatalError("No front camera device found")
        }
        
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer)
        else {
            debugPrint("Unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
    }
    
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    print("Number of faces detected: \(results.count)")
                    self.handleFaceDetectionResults(results)
                } else {
                    print("No faces detected")
                    self.clearDrawings()
                }
            }
        })
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        self.clearDrawings()
        
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({
            (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            //            faceBoundingBoxShape.strokeColor = UIColor.cyan.cgColor
            
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                
                // Compute new drawings
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
                
                // Handle calling SwiftUI binding
                self.callIsInBindingIfEyesAreInBindingBox(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.boxDrawings = facesBoundingBoxes
    }
    
    
    // Clear drawings to allow a clean canvas to display new drawings
    private func clearDrawings() {
        self.boxDrawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        
        return faceFeaturesDrawings
    }
    
    
    private func getEyePathPoints(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> [CGPoint] {
        let eyePathPoints = eye.normalizedPoints.map({ eyePoint in CGPoint(
            x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
            y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
        })
        
        return eyePathPoints
    }
    
    
    private func computeIfEyeIsInBoundingBox(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> Bool {
        let eyePathPoints = self.getEyePathPoints(eye,  screenBoundingBox: screenBoundingBox)
        /*
         Reasoning:
         
         All of the eye points x and y coordinates must be within the range of the x and y coordinates of the rectangleView's area
         
         left edge of rectangleView <= eye point x coordinate <= right edge of rectangleView
         &&
         top edge of rectangleView <= eye point y coordinate <= bottom edge of rectangleView
         
         */
        
        let isIn = eyePathPoints.allSatisfy { point in
            if ((rectangleView.frame.minX <= point.x) &&
                (point.x <= (rectangleView.frame.maxX)) &&
                (rectangleView.frame.minY <= point.y) &&
                (point.y <= (rectangleView.frame.maxY))) == true {
                
                return true
                
            } else {
                return false
            }
        }
        return isIn
        
    }
    
    
    private func callIsInBindingIfEyesAreInBindingBox(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) {
        
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            let bothEyesAreIn =
            computeIfEyeIsInBoundingBox(leftEye, screenBoundingBox: screenBoundingBox) &&
            computeIfEyeIsInBoundingBox(rightEye, screenBoundingBox: screenBoundingBox)
            
            if let binding = self.isInBindingCVVC {
                binding.wrappedValue = bothEyesAreIn
            }
        }
        
    }
    
    
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = self.getEyePathPoints(eye,  screenBoundingBox: screenBoundingBox)
        
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
        
        return eyeDrawing
    }
    
}


