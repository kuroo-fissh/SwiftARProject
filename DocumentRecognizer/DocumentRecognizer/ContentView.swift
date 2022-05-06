//
//  ContentView.swift
//  DocumentRecognizer
//
//  Created by 肖鱼欣 on 2022/5/6.
//

import SwiftUI
import RealityKit
import ARKit
import Vision

struct ContentView : View {
    
    @State var isPlacementEnable = false
    var model : (String) = "flower_tulip"
    @State var selectedmodel: String?
    @State var confirmModel : String?
    @State var documentDetected = false
    @State var documentTexts : String = " "
    @State var screenwidth = UIScreen.main.bounds.width
    @State var screenheight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(confirmModel: self.$confirmModel, documentDetected: self.$documentDetected, documentTexts: self.$documentTexts).ignoresSafeArea()
            
            VStack{
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.black.opacity(0.3))
                    Text(documentTexts).font(.system(size: 20))
                    
                }
                Button {
                    print("DEBUG: execute document detection")
                    DocumentDetection()
                    
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: screenwidth/1.2, height: 100)
                            .foregroundColor(Color.black.opacity(0.2))
                        Text("Detect")
                    }
                }

            }.frame(width: screenwidth/1.2, height: 300)
        }
    }
    
    func DocumentDetection(){
        
        let documentDetectRequest = VNDetectDocumentSegmentationRequest()
        let document = documentDetectRequest.results?.first
        
        if document != nil {
            documentDetected = true
            print("DEBUG: document detected")
            documentTexts += "There is a document!\n"
        }
        
        var textDetectRequest : [VNRecognizedTextObservation] = []
        
        let ocrDetection = VNRecognizeTextRequest{ request, error in
            textDetectRequest = request.results as! [VNRecognizedTextObservation]
        }
        
        for currentTexts in textDetectRequest{
            let foundText = currentTexts.topCandidates(1)
            documentTexts += foundText.first!.string + " "
            print("DEBUG: current texts : \(foundText.first!.string)")
        }
//        textDetectRequest.recognitionLevel = .accurate
//        textDetectRequest.usesLanguageCorrection = false
//
//        let supportedLanguages = try?textDetectRequest.supportedRecognitionLanguages()
//        textDetectRequest.recognitionLanguages = ["en-US", "zh-Hans"]

    }
}

struct DetectDocumentView : View{
    
    @Binding var documentDetected : Bool
    @Binding var documentTexts : String
    
    var body: some View{
        Text("ddd")
    }
    
//    func DocumentDetection(){
//
//
//
//        let documentDetectRequest = VNDetectDocumentSegmentationRequest()
//        let document = documentDetectRequest.results?.first
//
//        if document != nil {
//            documentDetected = true
//            print("DEBUG: document detected")
//            documentTexts += "There is a document!\n"
//        }
//
//        var textDetectRequest : [VNRecognizedTextObservation] = []
//
//        let ocrDetection = VNRecognizeTextRequest{ request, error in
//            textDetectRequest = request.results as! [VNRecognizedTextObservation]
//        }
//
//        for currentTexts in textDetectRequest{
//            let foundText = currentTexts.topCandidates(1)
//            documentTexts += foundText.first!.string + " "
//            print("DEBUG: current texts : \(foundText.first!.string)")
//        }
////        textDetectRequest.recognitionLevel = .accurate
////        textDetectRequest.usesLanguageCorrection = false
////
////        let supportedLanguages = try?textDetectRequest.supportedRecognitionLanguages()
////        textDetectRequest.recognitionLanguages = ["en-US", "zh-Hans"]
//
//    }
}

struct PlacementButtonView : View{
    
    @Binding var isPlacementEnable : Bool
    @Binding var selectedmodel : String?
    @Binding var confirmModel : String?
    
    var body: some View{
        HStack{
            
            //Cancel
            Button {
                print("DEBUG: click button cancel")
                self.isPlacementEnable = false
                self.selectedmodel = nil
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 80, height: 80)
                    .aspectRatio(1/1,contentMode: .fill)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(40)
                    .padding(20)
            }
            
            //Confirm
            Button {
                print("DEBUG: click button confirm")
                self.confirmModel = self.selectedmodel
                self.selectedmodel = nil
                self.isPlacementEnable = false
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 80, height: 80)
                    .aspectRatio(1/1,contentMode: .fill)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(40)
                    .padding(20)
            }
        }
    }
}

struct ModelPicker: View{
    
    var model : String
    @Binding var isPlacementEnable : Bool
    @Binding var selectedmodel : String?
    
    var body: some View{
        ScrollView(.horizontal){
            Button(action: {
                print("DEBUG: click button")
                self.isPlacementEnable = true
                self.selectedmodel = self.model
            }, label: {
                Image(uiImage: UIImage(named: "flower_tulip")!)
                    .resizable()
                    .frame(height: 150)
                    .aspectRatio(1/1, contentMode: .fill)
                    .background(Color.white)
                    .cornerRadius(12)
            })
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var confirmModel : String?
    @Binding var documentDetected : Bool
    @Binding var documentTexts : String
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        config.environmentTexturing = .automatic
//
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
//            config.sceneReconstruction = .mesh
//        }
//
//        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    
//        if let modelname = self.confirmModel{
//            print("DEBUG: modelname: \(modelname)")
//            let filename = modelname + ".usdz"
//            let modelEntity = try!ModelEntity.loadModel(named: filename)
//            let anchorEntity = AnchorEntity(plane: .any)
//            anchorEntity.addChild(modelEntity)
//            uiView.scene.addAnchor(anchorEntity)
//            DispatchQueue.main.async {
//                self.confirmModel = nil
//            }
//        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
