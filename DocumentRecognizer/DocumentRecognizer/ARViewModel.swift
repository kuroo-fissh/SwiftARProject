import RealityKit
import SwiftUI
import ARKit
import SpriteKit

class ARViewModel: ObservableObject {
    var arView: ARView
    var skView: ARSKView
    var tulipEntity : Entity
    
    init(){
        arView = ARView()
        arView.setupForARWorldConfiguration()
        skView = ARSKView()
        guard let entity = try? ModelEntity.load(named: "flower_tulip") else {fatalError()}
        tulipEntity = entity
//        arView.addCoaching()
//        arView.debugOptions = [.showAnchorOrigins, .showAnchorGeometry]
    }
}

extension ARView{
    func setupForARWorldConfiguration(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.isAutoFocusEnabled = true
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        self.session.run(configuration)
    }
    
    func placePlane(at position: SIMD3<Float>) {
        
    }
}



extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching(){
    let coachingOverlay = ARCoachingOverlayView()
         coachingOverlay.delegate = self
         coachingOverlay.session = self.session
         coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         coachingOverlay.translatesAutoresizingMaskIntoConstraints = true
         coachingOverlay.goal = .anyPlane
         self.addSubview(coachingOverlay)
     }
}


