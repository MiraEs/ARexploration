import ARKit

class GameScene: SKScene {
  
  //MARK: CONSTANTS
  private let neuralIntensity: CGFloat = 1000
  private var blendFactor: CGFloat?
  private var currentFrame: ARFrame? {
    didSet {
      currentFrame = sceneView.session.currentFrame
    }
  }
  
  //MARK: PRIVATE PROPERTIES
  private var isWorldSetUp = false
  
  private var sceneView: ARSKView {
    return view as! ARSKView
  }
  
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetUp {
      setUpWorld()
    }
    
    lightEstimate()
    setShadow()
  }
  
  //MARK: SETUP
  
  private func lightEstimate() {
    guard let currentFrame = currentFrame, let lightEstimate = currentFrame.lightEstimate else {
        return
    }
    
    let ambientIntensity = min(lightEstimate.ambientIntensity, neuralIntensity)
    blendFactor = 1 - ambientIntensity / neuralIntensity
  }
  
  private func setShadow() {
    guard let blendFactor = blendFactor else {
      return
    }
    
    for node in children {
      if let bug = node as? SKSpriteNode {
        bug.color = .black
        bug.colorBlendFactor = blendFactor
      }
    }
  }
  
  private func setUpWorld() {
    guard let currentFrame = currentFrame else {
      return
    }
    
    //Sets node/image 0.3m in front of you in a 4x4 matrix, in front of camera
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -0.3
    
    let transform = currentFrame.camera.transform * translation
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)
    
    isWorldSetUp = true
  }
}
