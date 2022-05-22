//
//  ContentView.swift
//  DocumentRecognizer
//
//  Created by 肖鱼欣 on 2022/5/6.
//

import SwiftUI
import CoreML
import RealityKit
import ARKit
import Vision

struct ContentView : View {
    @StateObject var arViewModel = ARViewModel()
    @State var isPlacementEnable = false
    @State var models : [Model] = [Model(image: Image("flower_tulip"), name: "flower_tulip"), Model(image: Image("toy_biplane"), name: "toy_biplane")]
    @State var modelConfirmForPlacement : Model?
    @State var selectedmodel: String?
    @State var confirmModel : String?
    @State var documentDetected = false
    @State var documentTexts : String = " "
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    @State var addModel = false
    @State var DetectModelName = " "
    
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(confirmModel: self.$confirmModel, documentDetected: self.$documentDetected, actiondocumentTexts: self.$documentTexts, actiondetectModelName: self.$DetectModelName, addModel: self.$addModel).ignoresSafeArea()
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.white.opacity(0.3))
                    VStack(alignment: .leading){
                        Text("Detect texts: \(documentTexts)").font(.system(size: 20))
                        Text("Detect models: \(DetectModelName)").font(.system(size: 20))
                    }
                }.frame(width: screenwidth/1.2, height: 150, alignment: .leading)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.white.opacity(0.3))
                    HStack{
                        Image("flower_tulip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                modelConfirmForPlacement = Model(image: Image("flower_tulip"), name: "flower_tulip")
                            }
                        Image("toy_biplane")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                modelConfirmForPlacement = Model(image: Image("toy_biplane"), name: "toy_biplane")
                            }
                        Button {
                            addModel = true
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 10).foregroundColor(Color.white.opacity(0.3))
                                Image(systemName: "checkmark.square").font(.system(size: 40))
                            }.frame(width: 100, height: 100)
                        }

                        
                    }
                }.frame(width: screenwidth/1.2, height: 110)
            }.frame(width: screenwidth/1.2, height: 200, alignment: .leading)
        }
        .environmentObject(arViewModel)
    }
}

struct Model {
    var image : Image
    var name : String
}

public func createclassificationRequest() -> VNCoreMLRequest
{
    let classificationRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        do {
            let coreMLModel = try MLModel(contentsOf: #fileLiteral(resourceName: "CheckIdentifier.mlmodelc"))
            let model = try VNCoreMLModel(for: coreMLModel)
            
            return VNCoreMLRequest(model: model)
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }()
    return classificationRequest
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}

public func observationLinesUp(_ observation: VNRectangleObservation, with textObservation: VNRecognizedTextObservation ) -> Bool {
    // calculate center
    let midPoint =  CGPoint(x:textObservation.boundingBox.midX, y:observation.boundingBox.midY)
    return textObservation.boundingBox.contains(midPoint)
}

public func perspectiveCorrectedImage(from inputImage: CIImage, rectangleObservation: VNRectangleObservation ) -> CIImage? {
    let imageSize = inputImage.extent.size
    
    // Verify detected rectangle is valid.
    let boundingBox = rectangleObservation.boundingBox.scaled(to: imageSize)
    guard inputImage.extent.contains(boundingBox)
    else { print("invalid detected rectangle"); return nil}
    
    // Rectify the detected image and reduce it to inverted grayscale for applying model.
    let topLeft = rectangleObservation.topLeft.scaled(to: imageSize)
    let topRight = rectangleObservation.topRight.scaled(to: imageSize)
    let bottomLeft = rectangleObservation.bottomLeft.scaled(to: imageSize)
    let bottomRight = rectangleObservation.bottomRight.scaled(to: imageSize)
    let correctedImage = inputImage
        .cropped(to: boundingBox)
        .applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    return correctedImage
}
