import SwiftUI
import ARKit
import SceneKit
import RealityKit
import Vision
import CoreML

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var arViewModel: ARViewModel
    @Binding var confirmModel: String?
    @Binding var documentDetected : Bool
    @Binding var actiondocumentTexts : String
    @Binding var actiondetectModelName : String
    @Binding var addModel : Bool
    
    func makeUIView(context: Context) -> ARView {
        arViewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if addModel {
            guard let entity = try? ModelEntity.load(named: "flower_tulip") else {fatalError()}
            let anchorEntity = AnchorEntity()
            anchorEntity.addChild(entity)
            arViewModel.arView.scene.addAnchor(anchorEntity)
            DispatchQueue.main.async {
                addModel = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate{
        var frameCounter = 0
        var queueSamplingCounter = 0
        let queueSize = 60
        let handPosePredictionInterval = 5
        var parent: ARViewContainer

        var handPoseRequest = VNDetectHumanHandPoseRequest() // only need one
        let queueSamplingCount = 60
        var queue = [MLMultiArray]()

        init(_ arViewContainer: ARViewContainer){
            parent = arViewContainer

            super.init()
            parent.arViewModel.arView.session.delegate = self
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            frameCounter += 1
            //Capture image from frame
            let pixelBuffer = frame.capturedImage
            let capturedImage = CIImage(cvPixelBuffer: pixelBuffer)

            //Detect document
            let documentDetectRequest = VNDetectDocumentSegmentationRequest()
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do{
                try requestHandler.perform([documentDetectRequest])
            }catch{}

//            print("DEBUG: after request handler")
            guard let document = documentDetectRequest.results?.first else { fatalError("DEBUG: no document found") }

            guard let documentImage = perspectiveCorrectedImage(from: capturedImage, rectangleObservation: document)
            else{ fatalError("")}

            if(frameCounter % 3 == 0){
                let documentRequestHandler = VNImageRequestHandler(ciImage: documentImage)

                //Recognize text on document
                var textBlocks: [VNRecognizedTextObservation] = []

                let ocrRequest = VNRecognizeTextRequest { request, error in
                    textBlocks = request.results as! [VNRecognizedTextObservation]
                }
                let textRequest = VNRecognizeTextRequest()
                // 设置工作模式 .fast 或者 .accurate
                textRequest.recognitionLevel = .accurate
                // 是否启用语言矫正
                textRequest.usesLanguageCorrection = false
                let supportLanauages = try? textRequest.supportedRecognitionLanguages() // iOS 15才有的api
                // ["en-US", "fr-FR", "it-IT", "de-DE", "es-ES", "pt-BR", "zh-Hans", "zh-Hant"]
                textRequest.recognitionLanguages = ["zh-Hans", "zh-Hant"]
                var documentTexts = " "
                //Perform text recognition on the document
                do{
                    try documentRequestHandler.perform([ocrRequest, textRequest])
                }catch{}
                for currentText in textBlocks {
                        let foundTextObservation = currentText.topCandidates(1)
                        documentTexts += foundTextObservation.first!.string
                        print("DEBUG: documentTexts: \(documentTexts)")
                }
                var modelName = " "
                if documentTexts.contains("hope"){
                    modelName = "flower_tulip"
                }
                if documentTexts.contains("Study"){
                    modelName = "toy_biplane"
                }
                DispatchQueue.main.async {
                    self.parent.actiondocumentTexts = documentTexts
                    self.parent.actiondetectModelName = modelName
                    if !modelName.isEmpty
                    {
                        self.parent.addModel = false
                    }
                    self.parent.confirmModel = modelName
                }

            }
        }
    }
    
}
